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

# Default and parse arguments
android_ndk=false
gcloud=false
check_base_tools=false
large_test=false
android_api=""
android_build_tools=""

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

# Validate required arguments
if [ -z "$android_api" ] || [ -z "$android_build_tools" ]; then
  usage
fi

# Base tools check with comprehensive version reporting
if [ "$check_base_tools" = true ]; then
  echo "Java Versions:"
  java -version
  javac -version
  echo "Full Java Version Details:"
  java --version

  echo "Ruby Version:"
  ruby -v
  rbenv -v
  # if HOME is changed, rbenv should still have access to the install plugin
  echo "Checking rbenv plugin installation:"
  (
    # Changing HOME environment variable in this subshell
    export HOME="/tmp"
    rbenv install --skip-existing 2.7.1
  )

  echo "SSH Version:"
  ssh -V
fi

if [ "$gcloud" = true ]; then
  # Check if gcloud sdk is installed
  gcloud --version
fi

# Setup test app environment variables
export KOTLIN_VERSION="1.9.20"
export GRADLE_VERSION="8.5"
export ANDROID_GRADLE_TOOLS_VERSION="8.2.0"
export COMPILE_SDK_VERSION="$android_api"
export BUILD_TOOLS_VERSION="$android_build_tools"
export MIN_SDK_VERSION=21
export TARGET_SDK_VERSION="$android_api"
export NDK_VERSION="26.1.10909125"

# Function to setup gradle version in wrapper properties
setup_gradle_version() {
  if grep -q "distributionUrl" ./gradle/wrapper/gradle-wrapper.properties; then
    file="./gradle/wrapper/gradle-wrapper.properties"
    tail -n 1 "$file" | wc -c | xargs -I {} truncate "$file" -s -{}
  fi

  echo "distributionUrl=https\://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip" >> ./gradle/wrapper/gradle-wrapper.properties
}

# Function to execute test
exec_test() {
  cd "$1"

  setup_gradle_version

  gem install bundler:2.3.7
  bundle install
  bundle exec fastlane android build
}

# Prepare environment
ruby -v
eval "$(jenv init -)"

# Use Java 21 as default
jenv global 21

# Run tests based on NDK flag
if [ "$android_ndk" = true ]; then
  echo "Running tests with ndk"
  exec_test "$script_path"/test-app-ndk
else
  echo "Running tests"
  exec_test "$script_path"/test-app
fi

# Run large tests if requested
if [ "$large_test" = true ]; then
  echo "Run android tests on Firebase Test Lab"
  cd "$script_path"/test-firebase-test-lab

  setup_gradle_version

  bundle install
  bundle exec fastlane android integrated_test
fi

exit 0
