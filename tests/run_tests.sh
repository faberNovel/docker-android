# Exit immediately if a command returns a non-zero status.
set -e

script_path="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Usage of this script
script_name=$0
usage() {
    echo "usage: $script_name [--android_ndk]"
    echo " --android_ndk Test with NDK application"
    exit 1
}

while true; do
  case "$1" in
    --android_ndk ) android_ndk=true; shift ;;
    * ) break ;;
  esac
done

java -version
rbenv -v

# Setup test app environment variables
export KOTLIN_VERSION="1.3.71"
export ANDROID_GRADLE_TOOLS_VERSION="3.6.1"
export COMPILE_SDK_VERSION=29
export BUILD_TOOLS_VERSION="29.0.2"
export MIN_SDK_VERSION=21
export TARGET_SDK_VERSION=29
export NDK_VERSION="21.0.6113669"


if [ "$android_ndk" = true ]; then
  echo "Running tests with ndk"
  cd "$script_path"/test-app-ndk
else
  echo "Running tests"
  cd "$script_path"/test-app
fi

ruby -v
gem install bundler:2.1.4
bundle install
bundle exec fastlane android build

exit 0
