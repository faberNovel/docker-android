#!/bin/sh

# Exit immediately if a command returns a non-zero status.
set -e

# Supported android builds tools
android_build_tools="29.0.3"

# Usage of this script
program_name=$0
usage () {
  echo "usage: $program_name [--android-api 29] [--build] [--test]"
  echo "  --android-api <androidVersion> Use specific Android version from \`sdkmanager --list\`"
  echo "  --android-ndk                  Install Android NDK"
  echo "  --ndk-version <version>        Install a specific Android NDK version from \`sdkmanager --list\`"
  echo "  --build                        Build image"
  echo "  --test                         Test image"
  echo "  --large-test                   Run large tests on the image (Firebase Test Lab for example)"
  echo "  --deploy                       Deploy image"
  echo "  --desc                         Generate a .md file in /desc/ouput folder describing the builded image, on host machine"
  exit 1
}

# Parameters parsing
android_ndk=false
large_test=false

while true; do
  case "$1" in
    --android-api ) android_api="$2"; shift 2 ;;
    --build ) build=true; shift ;;
    --test ) test=true; shift ;;
    --android-ndk ) android_ndk=true; shift ;;
    --large-test ) large_test=true; shift ;;
    --ndk-version ) ndk_version="$2"; shift 2 ;;
    --deploy ) deploy=true; shift ;;
    --desc ) desc=true; shift ;;
    * ) break ;;
  esac
done

if [ -z "$android_api" ]; then
  usage
fi

if [ $large_test = true ]; then
    failed=false
    if [ -z "$GCLOUD_SERVICE_KEY" ]; then
        echo "GCLOUD_SERVICE_KEY environment variable is need to run large tests"
        failed=true
    fi
    if [ -z "$FIREBASE_PROJECT_ID" ]; then
        echo "FIREBASE_PROJECT_ID environment variable is need to run large tests"
        failed=true
    fi
    if [ "$failed" = true ]; then
        exit 1
    fi
fi

# Compute image tag
org_name=fabernovel
simple_image_name=api-$android_api
if [ "$android_ndk" = true ]; then
  simple_image_name="$simple_image_name-ndk"
fi
branch=${GIT_REF##refs/heads/}
if [ "$branch" = "develop" ]; then
  simple_image_name="$simple_image_name-snapshot"
fi
if [ -n "$RELEASE_NAME" ]; then
  simple_image_name="$simple_image_name-$RELEASE_NAME"
fi

full_image_name="$org_name/android:$simple_image_name"

# CI business
tasks=0
if [ "$build" = true ]; then
  tasks=$((tasks+1))
  if [ -n "$ndk_version" ]; then
    ndk_version_build_arg="--build-arg ndk_version=$ndk_version"
  fi
  echo $ndk_version_build_arg
  set -x
  docker build \
    --build-arg android_api=android-$android_api \
    --build-arg android_ndk="$android_ndk" \
    $ndk_version_build_arg \
    --tag $full_image_name .
  set +x
fi

ci=${CI:-false}
if [ "$ci" = true ]; then
  echo "Running in CI"
  volume_options="--volumes-from runner --workdir $GITHUB_WORKSPACE"
else
  echo "Not running in CI"
  volume_options="-v $PWD:/wd --workdir /wd"
fi

if [ "$test" = true ]; then
    tasks=$((tasks+1))
    echo "Testing image $full_image_name"
    test_options="--android-api $android_api --android-build-tools $android_build_tools"
    if [ "$android_ndk" = true ]; then
        test_options="$test_options --android-ndk"
    fi
    if [ "$large_test" = true ]; then
        echo "Large test: $FIREBASE_PROJECT_ID"
        tasks=$((tasks+1))
        set -x
        docker run \
        --env FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID}" \
        --env GCLOUD_SERVICE_KEY="${GCLOUD_SERVICE_KEY}" \
        $volume_options \
        --rm \
        "$full_image_name" \
        sh tests/run_tests.sh $test_options --large-test
        set +x
    else
        set -x
        docker run \
        $volume_options \
        --rm \
        "$full_image_name" \
        sh tests/run_tests.sh $test_options
        set +x
    fi
fi

if [ "$deploy" = true ]; then
  tasks=$((tasks+1))
  echo "Deploy image $full_image_name"
  echo "$DOCKERHUB_TOKEN" | docker login --username vincentbrison --password-stdin
  docker push $full_image_name
fi

if [ "$desc" = true ]; then
  tasks=$((tasks+1))
  echo "Generating image description $simple_image_name.md"
  docker run \
    $volume_options \
    --rm $full_image_name \
    sh desc/desc.sh | tee desc/output/$simple_image_name.md
fi

if [ "$tasks" = 0 ]; then
  echo "No task was executed"
  usage
fi
