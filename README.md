# macOS Catalina Beta Killing Dart Process Minimal Reproduction

This is a minimal reproduction of
[Flutter issue #33890](https://github.com/flutter/flutter/issues/33890). That
issue is for the `flutter upgrade` flow, but it is not specific to Flutter. It
seems that if a `dart` application deletes the `dart` binary that is running
its process, and then subsequently starts a new external process via
`Process.runSync()`, the OS will (usually) kill the subprocess.

To test this out, `git clone` this repository locally, `cd` into the
directory, and execute the BASH script `./run.sh`. This is a summary of what
the BASH script does:

1. Downloads a copy of the Dart SDK (code copy/paste/modified from the Flutter
tool) and caches it to `/path/to/this/repo/dart-sdk`, so repeat runs do not
need to download.
1. Copies the actual Dart binary to the root directory of the repo.
1. Invokes the local Dart binary to run the Dart application `main.dart`.
1. Inside `main.dart`, the local Dart binary file that is currently running
is deleted.
1. Next, an arbitrary shell command is called via `Process.runSync()`.
1. The results of this child process are logged, including exit code and PID.

If the child process is successful (the desired behavior), the exit code
should be `0`. This is what happens if run on macOS pre-Catalina. However,
on Catalina, *most* times (not sure about the exceptions, potentially a race
condition?) the exit code will be `-9`, which means it was given SIGKILL.

The BASH script also logs to two files: `script.log` and `sys.log`. The former
is merely the output of the script itself, while the latter is a snapshot of
the OS system logs while the script ran. Here is a sample:

```
==> script.log <==
Mon Jul 29 10:29:50 PDT 2019 Starting BASH script...

You are on the macOS Catalina Beta. It is expected the exit code of the subprocess to be -9...most times. Sometimes it is 0.

Mon Jul 29 10:29:50 PDT 2019 Starting up the dart app main.dart...
Deleting dart...
Executing uname...
Process executed:
  exit code: -9
  pid: 96735
  stdout:
1
  stderr:

Mon Jul 29 10:29:52 PDT 2019 Exiting BASH script.

==> sys.log <==
2019-07-29 10:29:51.682287-0700 0x1ab934   Default     0x0                  0      0    kernel: (corecapture) 604153.062623 wlan0.A[82112] updateLQM@3328:No per core RSSI to report
2019-07-29 10:29:51.847100-0700 0x1abb14   Default     0x0                  0      0    kernel: (AppleSystemPolicy) initiating malware scan (chgtime: 1564421391 lastFileScanTime: 1564421390 pid: 96735 info_path: /Users/flutter/minimal-dart-bug-app/dart proc_path: /Users/flutter/minimal-dart-bug-app/dart
2019-07-29 10:29:51.847223-0700 0x1abaf9   Error       0x0                  148    0    syspolicyd: Unable (errno: 2) to read file at <private> for pid: 96735 process path: <private> library path: (null)
2019-07-29 10:29:51.847260-0700 0x1abaf9   Error       0x0                  148    0    syspolicyd: Terminating process due to Malware rejection: 96735, <private>
2019-07-29 10:29:51.847284-0700 0x1abaf9   Default     0x0                  0      0    kernel: build_userspace_exit_reason: illegal flags passed from userspace (some masked off) 0x141, ns: 9, code 0x8
2019-07-29 10:29:51.847330-0700 0x1abb14   Default     0x0                  0      0    kernel: (AppleSystemPolicy) Sleep interrupted, signal 0x100
2019-07-29 10:29:51.847342-0700 0x1abb14   Default     0x0                  0      0    kernel: (AppleSystemPolicy) Security policy would not allow process: 96735, /Users/flutter/minimal-dart-bug-app/dart
2019-07-29 10:29:51.858824-0700 0x1abb16   Default     0x0                  0      0    kernel: (AppleSystemPolicy) initiating malware scan (chgtime: 1564421391 lastFileScanTime: 1564421390 pid: 96736 info_path: /Users/flutter/minimal-dart-bug-app/dart proc_path: /Users/flutter/minimal-dart-bug-app/dart
2019-07-29 10:29:51.859045-0700 0x1aba37   Error       0x0                  148    0    syspolicyd: Unable (errno: 2) to read file at <private> for pid: 96736 process path: <private> library path: (null)
2019-07-29 10:29:51.859114-0700 0x1aba37   Error       0x0                  148    0    syspolicyd: Terminating process due to Malware rejection: 96736, <private>
2019-07-29 10:29:51.859161-0700 0x1aba37   Default     0x0                  0      0    kernel: build_userspace_exit_reason: illegal flags passed from userspace (some masked off) 0x141, ns: 9, code 0x8
2019-07-29 10:29:51.859246-0700 0x1abb16   Default     0x0                  0      0    kernel: (AppleSystemPolicy) Sleep interrupted, signal 0x100
2019-07-29 10:29:51.859265-0700 0x1abb16   Default     0x0                  0      0    kernel: (AppleSystemPolicy) Security policy would not allow process: 96736, /Users/flutter/minimal-dart-bug-app/dart
```
