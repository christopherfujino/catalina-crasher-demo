#!/bin/bash

set -euo pipefail

exec > >(tee -ia script.log)

START_TIME=$(date -jn '+%Y-%m-%d %H:%M:%S')
echo $START_TIME
echo "$(date -jn) Starting BASH script..."

PATTERN='Darwin Kernel Version 19\.[0-9]{1,2}\.[0-9]{1,2}'

echo
if ! [[ $(uname -v) =~ $PATTERN ]]; then
  echo 'You are not on the macOS Catalina Beta. It is expected the exit code of the subprocess to be 0.'
else
  echo 'You are on the macOS Catalina Beta. It is expected the exit code of the subprocess to be -9...most times. Sometimes it is 0.'
fi
echo

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
DART_SCRIPT='main.dart'
# An arbitrary, recent Flutter Engine commit revision
ENGINE_VERSION='72341ed032867b36ba97b05c5e3b76af0a197ba5'
DART_ZIP_NAME='dart-sdk-darwin-x64.zip'
DART_ZIP_PATH="$SCRIPT_DIR/$DART_ZIP_NAME"
# This is the same location the flutter tool downloads the dart-sdk from
DART_SDK_URL="https://storage.googleapis.com/flutter_infra/flutter/$ENGINE_VERSION/$DART_ZIP_NAME"
DART_DIR_NAME="$SCRIPT_DIR/dart-sdk"
DART_BINARY_PATH="$DART_DIR_NAME/dart-sdk/bin/dart"
DART_COPY_BINARY_PATH="$SCRIPT_DIR/dart"

if [ ! -f $DART_BINARY_PATH ]; then
  echo 'Downloading the dart sdk...'
  curl --continue-at - --location --output "$DART_ZIP_PATH" "$DART_SDK_URL" 2>&1 || {
    echo "Failed to retrieve the Dart SDK from: $DART_SDK_URL"
    rm -f -- "$DART_ZIP_PATH"
    exit 1
  }
  unzip -o -q "$DART_ZIP_PATH" -d "$DART_DIR_NAME" || {
    echo "It appears that the downloaded file is corrupt; please try again."
    rm -f -- "$DART_ZIP_PATH"
    exit 1
  }
  rm -f -- "$DART_ZIP_PATH"
fi

# Make a copy of the dart binary
cp $DART_BINARY_PATH $DART_COPY_BINARY_PATH

echo "$(date -jn) Starting up the dart app $DART_SCRIPT..."
# Invoke our dart app using the local copy of the dart binary,
# which the app will delete
$DART_COPY_BINARY_PATH $DART_SCRIPT

[ $(uname) = 'Darwin' ] && log show --start "$START_TIME" > sys.log

echo "$(date -jn) Exiting BASH script."
