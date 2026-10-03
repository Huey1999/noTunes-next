import SwiftUI
import AppKit
import Darwin

@main
struct NoTunesNextApp: App {
    @StateObject private var controller = MusicBlockController()

    var body: some Scene {
        MenuBarExtra(
            "noTunes Next",
            systemImage: (controller.enabled && controller.listenerReady)
                ? "music.note.slash"
                : "music.note"
        ) {
            Button(
                (controller.enabled && controller.listenerReady)
                    ? "Disable"
                    : "Enable"
            ) {
                controller.toggleEnabled()
            }

            Divider()

            Text(
                (controller.enabled && controller.listenerReady)
                    ? "Protection enabled"
                    : "Protection disabled"
            )
            .foregroundStyle(.secondary)

            Divider()

            Button("Quit") {
                controller.stop()
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}

final class MusicBlockController: ObservableObject {
    @Published private(set) var enabled = true
    @Published private(set) var listenerReady = false

    private var logProcess: Process?
    private var pipe: Pipe?
    private var buffer = Data()

    private let stateLock = NSLock()
    private var interceptionEnabled = true

    private let predicate =
        #"process == "mediaremoted" AND eventMessage CONTAINS[c] "Destination app com.apple.Music not available" AND eventMessage CONTAINS[c] "command requested a launch" AND eventMessage CONTAINS[c] "com.apple.bluetoothd""#

    init() {
        start()

        // Keep the startup behavior consistent with the tested shell version:
        // give log stream one second to become ready before protection is active.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            sleep(1)

            guard let self else { return }

            self.stateLock.lock()
            self.interceptionEnabled = true
            self.stateLock.unlock()

            DispatchQueue.main.async {
                self.listenerReady = true
            }
        }
    }

    deinit {
        stop()
    }

    func toggleEnabled() {
        guard listenerReady else { return }

        // The UI intentionally stays unchanged for one second.
        // This makes the displayed state match the point at which the
        // internal interception state actually changes.
        let targetEnabled = !enabled

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            sleep(1)

            guard let self else { return }

            self.stateLock.lock()
            self.interceptionEnabled = targetEnabled
            self.stateLock.unlock()

            DispatchQueue.main.async {
                self.enabled = targetEnabled
            }
        }
    }

    func start() {
        guard logProcess == nil else { return }

        let process = Process()
        let output = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/log")
        process.arguments = [
            "stream",
            "--style", "compact",
            "--info",
            "--predicate", predicate
        ]
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice

        output.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            self?.consume(data)
        }

        do {
            try process.run()
            logProcess = process
            pipe = output
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.enabled = false

                self?.stateLock.lock()
                self?.interceptionEnabled = false
                self?.stateLock.unlock()
            }
        }
    }

    func stop() {
        pipe?.fileHandleForReading.readabilityHandler = nil

        if let process = logProcess, process.isRunning {
            process.terminate()
        }

        logProcess = nil
        pipe = nil
        buffer.removeAll(keepingCapacity: false)

        stateLock.lock()
        interceptionEnabled = false
        stateLock.unlock()
    }

    private func consume(_ data: Data) {
        buffer.append(data)

        while let newline = buffer.firstIndex(of: 0x0A) {
            let lineData = buffer.subdata(in: 0..<newline)
            buffer.removeSubrange(0...newline)

            guard let line = String(data: lineData, encoding: .utf8) else {
                continue
            }

            stateLock.lock()
            let shouldBlock = interceptionEnabled
            stateLock.unlock()

            guard shouldBlock else {
                continue
            }

            if line.contains("Destination app com.apple.Music not available for command") {
                blockMusicLikeTestedScript()
            }
        }
    }

    // Mirrors the tested shell behavior:
    // sleep 0.05 -> find Music -> send SIGTERM.
    private func blockMusicLikeTestedScript() {
        DispatchQueue.global(qos: .userInteractive).async {
            usleep(50_000)

            let apps = NSRunningApplication.runningApplications(
                withBundleIdentifier: "com.apple.Music"
            )

            for app in apps where !app.isTerminated {
                _ = Darwin.kill(app.processIdentifier, SIGTERM)
            }
        }
    }
}
