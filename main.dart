import 'dart:io';

//const String oldBin = 'dart-old';
const String newBin = 'dart-new';
const String targetBin = 'dart';
const String helloWorldFile = 'helloWorld.dart';

void main() {
  //print('main start...');
  //ls();
  //dartVersion();

  print('deleting $targetBin file...');
  File(targetBin).deleteSync();

  printResults(Process.runSync('ps', []));

  //print('replacing dart with new version');
  //final File newDart = File(newBin);
  //newDart.copySync(targetBin);

  //ls();
  //dartVersion();

  //print('invoking second dart script...');
  //helloWorld();
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

void ls() {
  var pr = Process.runSync('uname', []);
  printResults(pr);
}

void dartVersion() {
  printResults(Process.runSync(targetBin, ['--version']));
}

void helloWorld() {
  printResults(Process.runSync(targetBin, [helloWorldFile]));
}
