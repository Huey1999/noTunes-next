# noTunes Next — macOS App

Native macOS menu bar prototype using the same event matching as the tested shell implementation.

The Music termination step now mirrors the tested script more closely: wait 50 ms, locate the Music process, and send the normal `SIGTERM` used by the shell `kill` command.

## Build

Requires macOS 13+ and the Swift compiler / Xcode Command Line Tools.

```bash
chmod +x build.sh install.sh uninstall.sh
./build.sh
```

Then run:

```bash
open "build/noTunes Next.app"
```

The app appears in the menu bar.

## Test

Disable the old `block_music_test.sh` LaunchAgent/background item before testing the App alone. Otherwise both implementations can intercept the same Music launch.

## Relationship to noTunes

Inspired by noTunes. noTunes Next is an independent implementation. It is not a fork of noTunes or noTunes Improved, and it does not use their source code.

## License

MIT License
