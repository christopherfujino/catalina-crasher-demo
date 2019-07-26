import 'dart:io';

const String newBin = 'dart-new';
const String targetBin = 'dart';

void main() {
  print('deleting $targetBin file...');
  File(targetBin).deleteSync();

  printResults(Process.runSync('ps', []));
}

void printResults(ProcessResult pr) {
  print(
    'Process executed:\n'
    '  exit code: ${pr.exitCode}\n'
    '  pid: ${pr.pid}\n'
    '  stdout:\n${pr.stdout}'
    '  stderr:\n${pr.stderr}'
  );
}
