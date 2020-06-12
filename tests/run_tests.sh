#!/bin/sh

# Exit immediately if a command returns a non-zero status.
set -e

script_path="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Usage of this script
script_name=$0
usage() {
    echo "usage: $script_name [--android-ndk] --android-api <api> --android-build-tools <build tools version>"
    echo " --android-ndk Test with NDK application"
    echo " --android-api Tests apps compile and target SDK"
    echo " --gcloud Tests if gcloud SDK was installed"
    echo " --check-base-tools Test base tools setup like Java, Ruby and other"
    echo " --android-build-tools Used android builds tools"
    echo " --large-test Run large tests on the image (Firebase Test Lab for example)"
    exit 1
}

setup_bundler() {
    ruby -v
    gem install bundler:2.1.4
}

while true; do
  case "$1" in
    --android-ndk ) android_ndk=true; shift ;;
    --gcloud ) gcloud=true; shift ;;
    --check-base-tools ) check_base_tools=true; shift ;;
    --android-api ) android_api=$2; shift 2 ;;
    --android-build-tools ) android_build_tools=$2; shift 2 ;;
    --large-test ) large_test=true; shift ;;
    * ) break ;;
  esac
done

if [ -z "$android_api" ]; then
  usage
fi

if [ -z "$android_build_tools" ]; then
  usage
fi

if [ "$check_base_tools" = true ]; then
  java -version
  rbenv -v
  ssh -V
fi

if [ "$gcloud" = true ]; then
  # Check if gcloud sdk is installed
  gcloud --version
fi

# Setup test app environment variables
export KOTLIN_VERSION="1.3.71"
export ANDROID_GRADLE_TOOLS_VERSION="3.6.1"
export COMPILE_SDK_VERSION="$android_api"
export BUILD_TOOLS_VERSION="$android_build_tools"
export MIN_SDK_VERSION=21
export TARGET_SDK_VERSION="$android_api"
export NDK_VERSION="21.0.6113669"


if [ "$android_ndk" = true ]; then
  echo "Running tests with ndk"
  cd "$script_path"/test-app-ndk
else
  echo "Running tests"
  cd "$script_path"/test-app
fi

setup_bundler
bundle install
bundle exec fastlane android build

if [ "$large_test" = true ]; then
    echo "Run android tests on Firebase Test Lab"
    cd "$script_path"/test-firebase-test-lab

    bundle install
    bundle exec fastlane android integrated_test
fi

exit 0
