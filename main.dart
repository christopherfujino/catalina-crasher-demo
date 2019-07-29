import 'dart:io';

void main() {
  // The local path to the binary that's running this script
  const String dartPath = 'dart';
  // Any arbitrary external command
  const String command = 'uname';

  print('Deleting $dartPath...');
  File(dartPath).deleteSync();

  print('Executing $command...');
  final ProcessResult result = Process.runSync(command, []);
  printResult(result);
}

void printResult(ProcessResult pr) {
  print(
    'Process executed:\n'
    '  exit code: ${pr.exitCode}\n'
    '  pid: ${pr.pid}\n'
    '  stdout:\n${pr.stdout}\n'
    '  stderr:\n${pr.stderr}'
  );
}
