#!/bin/bash

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
  # if HOME is changed, rbenv should still have access to the install plugin
  (
    # Changing HOME environment variable in this subshell
    export HOME="/tmp"
    rbenv install --skip-existing 2.7.1
  )
  ssh -V
fi

if [ "$gcloud" = true ]; then
  # Check if gcloud sdk is installed
  gcloud --version
fi

# Setup test app environment variables
export KOTLIN_VERSION="1.3.71"
export GRADLE_VERSION="7.3"
export ANDROID_GRADLE_TOOLS_VERSION="7.0.3"
export COMPILE_SDK_VERSION="$android_api"
export BUILD_TOOLS_VERSION="$android_build_tools"
export MIN_SDK_VERSION=21
export TARGET_SDK_VERSION="$android_api"
export NDK_VERSION="21.0.6113669"
jenv global 11

exec_test() {
  cd "$1"

  if grep -q "distributionUrl" ./gradle/wrapper/gradle-wrapper.properties; then
    file="./gradle/wrapper/gradle-wrapper.properties"
    tail -n 1 "$file" | wc -c | xargs -I {} truncate "$file" -s -{}
  fi

  echo "distributionUrl=https\://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip" >> ./gradle/wrapper/gradle-wrapper.properties
  gem install bundler:2.3.7
  bundle install
  bundle exec fastlane android build
}

ruby -v
eval "$(jenv init -)"

if [ "$android_ndk" = true ]; then
  echo "Running tests with ndk"
  exec_test "$script_path"/test-app-ndk
else
  echo "Running tests"
  exec_test "$script_path"/test-app
fi

if [ "$large_test" = true ]; then
    echo "Run android tests on Firebase Test Lab"
    cd "$script_path"/test-firebase-test-lab

    bundle install
    bundle exec fastlane android integrated_test
fi

if (( "$android_api" < 31 )); then
  export GRADLE_VERSION="5.6.4"
  export ANDROID_GRADLE_TOOLS_VERSION="3.6.1"
  jenv global 1.8
  exec_test "$script_path"/test-app-jdk-8

  jenv global 11
fi

exit 0
