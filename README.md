# noTunes Next

A lightweight macOS utility that prevents Bluetooth headphones from accidentally launching Apple Music.

## Why?

On macOS, Bluetooth headphones can send media-control commands to the system. When Apple Music is not playing, touching the controls on some Bluetooth headphones can cause macOS to launch the Music app even when you did not intend to open it.

For example:

- **Sony WH-1000XM4** — double-tapping the touch panel can launch Apple Music when nothing is playing.
- **Apple AirPods** — a similar double-tap/media-control action can also launch Apple Music when nothing is playing.

The purpose of **noTunes Next** is simple:

> **Prevent unwanted Bluetooth-triggered launches of Apple Music while keeping normal manual launches of Music working normally.**

## Testing Existing Solutions

Before creating noTunes Next, we tested two existing solutions.

### noTunes

**noTunes works** for preventing Apple Music from launching.

However, it also blocks normal manual launches of Apple Music while it is enabled.

If you want to open Music normally, you have to disable noTunes first.

For users who only want to prevent accidental launches caused by Bluetooth headphones, this can be inconvenient.

### noTunes Improved

We also tested **noTunes Improved**, including its headphone-triggered behavior.

In our testing, it did **not** prevent the Bluetooth-triggered Music launch with:

- Sony WH-1000XM4
- Apple AirPods

Therefore, it did not solve the specific problem we were trying to address.

## noTunes Next

noTunes Next was created specifically for this problem.

Instead of blocking Apple Music globally, it monitors the macOS `mediaremoted` events associated with a Bluetooth request to launch Apple Music.

When the matching event is detected, noTunes Next immediately terminates the newly launched Music process.

This allows normal manual launches of Music to continue working.

### Tested

| Test | Result |
|---|---|
| Sony WH-1000XM4 double-tap → Apple Music | ✅ Blocked |
| Apple AirPods double-tap → Apple Music | ✅ Blocked |
| Manually launch Apple Music | ✅ Works normally |

## How It Works

noTunes Next runs as a lightweight macOS `LaunchAgent`.

The basic event flow is:

```text
Bluetooth media command
        ↓
    mediaremoted
        ↓
Apple Music launch requested
        ↓
  noTunes Next detects it
        ↓
   Music is terminated
```

The script listens for the relevant `mediaremoted` event and checks for the Bluetooth-related Apple Music launch request.

When detected, it waits a very short interval and terminates the Music process.

It does **not** continuously block Apple Music.

## Features

- Lightweight shell script
- Runs in the background as a macOS LaunchAgent
- No menu bar application
- No third-party framework
- Does not modify Apple Music
- Does not disable Apple Music
- Blocks Bluetooth-triggered Music launches
- Allows normal manual Music launches
- Tested with Sony WH-1000XM4
- Tested with Apple AirPods

## Installation

Download the project and open the project directory in Terminal.

Run:

```bash
chmod +x install.sh
./install.sh
```

The installer will:

1. Install the blocking script to:

```text
~/Library/Scripts/noTunes-next/block_music.sh
```

2. Install the LaunchAgent to:

```text
~/Library/LaunchAgents/com.hking.notunes-next.plist
```

3. Start the LaunchAgent in the background.

After installation, noTunes Next runs automatically in the background. You do **not** need to keep Terminal open.

### Verify Installation

Run:

```bash
launchctl print gui/$(id -u)/com.hking.notunes-next | grep -E 'program =|state =|active count'
```

A running installation should show:

```text
active count = 1
state = running
program = /Users/yourname/Library/Scripts/noTunes-next/block_music.sh
```

## Uninstallation

Run:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

This will stop the LaunchAgent and remove the installed script and LaunchAgent.

## Technical Notes

noTunes Next does not identify a specific headphone model.

It listens for the relevant macOS `mediaremoted` event associated with a Bluetooth request to launch Apple Music.

The current implementation has been tested successfully with:

- Sony WH-1000XM4
- Apple AirPods

Because the implementation relies on macOS system events, other Bluetooth devices may also work if they generate the same event sequence.

## Limitations

noTunes Next relies on macOS `mediaremoted` system log events rather than a public API specifically designed to identify the physical device that triggered an application launch.

Therefore, this project does not claim that every Bluetooth device or every possible Music launch mechanism will behave identically.

The current implementation has been successfully tested with the devices listed above.

## Relationship to noTunes

noTunes Next is an **independent implementation**.

It is **not a fork of noTunes or noTunes Improved**, and it does not use their source code.

It was created to solve a specific macOS problem:

> Prevent accidental Bluetooth-triggered Apple Music launches while keeping normal manual launches available.

## License

MIT License
