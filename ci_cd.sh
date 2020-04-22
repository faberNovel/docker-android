#!/bin/bash

# Exit immediately if a command returns a non-zero status.
set -e

# Supported android builds tools
android_build_tools="29.0.3"

# Semver regex
nat='0|[1-9][0-9]*'
alphanum='[0-9]*[A-Za-z-][0-9A-Za-z-]*'
ident="$nat|$alphanum"
field='[0-9A-Za-z-]+'
semver_regex="^[vV]?($nat)\\.($nat)\\.($nat)(\\-(${ident})(\\.(${ident}))*)?(\\+${field}(\\.${field})*)?$"

# Usage of this script
program_name=$0
function usage {
  echo "usage: $program_name [--android_api 29] [--build] [--test]"
  echo "  --android_api androidVersion Use specific Android version from \`sdkmanager --list\`"
  echo "  --android_ndk                Install Android NDK"
  echo "  --ndk_version <version>      Install a specific Android NDK version from \`sdkmanager --list\`"
  echo "  --build                      Build image"
  echo "  --test                       Test image"
  echo "  --large-test                 Run large tests on the image (Firebase Test Lab for example)"
  echo "  --deploy                     Deploy image"
  echo "  --desc                       Generate a desc.txt file describing the builded image, on host machine"
  echo "  --image-name                 Print the image name base on parameters"
  exit 1
}

# Parameters parsing
android_ndk=false
large_test=false

while true; do
  case "$1" in
    --android_api ) android_api="$2"; shift 2 ;;
    --build ) build=true; shift ;;
    --test ) test=true; shift ;;
    --android_ndk ) android_ndk=true; shift ;;
    --large-test ) large_test=true; shift ;;
    --ndk_version ) ndk_version="$2"; shift 2 ;;
    --deploy ) deploy=true; shift ;;
    --desc ) desc=true; shift ;;
    --image-name ) print_image_name=true; shift ;;
    * ) break ;;
  esac
done

if [[ -z "$android_api" ]]; then
  usage
fi

# Compute image tag
org_name=fabernovel
simple_image_name=api-$android_api
if [[ $android_ndk == true ]]; then
  simple_image_name="$simple_image_name-ndk"
fi
branch=${GIT_REF##refs/heads/}
if [[ $branch == "develop" ]]; then
  simple_image_name="$simple_image_name-snapshot"
fi
tag=${GIT_REF##refs/tags/}
if [[ $tag =~ $semver_regex ]]; then
  simple_image_name="$simple_image_name-$tag"
fi

if [[ $print_image_name == true ]]; then
  echo $simple_image_name
  exit 0
fi

full_image_name="$org_name/android:$simple_image_name"

# CI business
tasks=0
if [[ $build == true ]]; then
  tasks=$((tasks+1))
  echo "Building image $full_image_name"
  if [[ -n "$ndk_version" ]]; then
    ndk_version_build_arg="--build-arg ndk_version=\"$ndk_version\""
  fi
  set -x
  docker build \
    --build-arg android_api=android-$android_api \
    --build-arg android_ndk="$android_ndk" \
    $ndk_version_build_arg \
    --tag $full_image_name .
  set +x
fi

if [[ $test == true ]]; then
    tasks=$((tasks+1))
    echo "Testing image $full_image_name"
    test_options="--android_api $android_api --android_build_tools $android_build_tools"
    if [[ "$android_ndk" == true ]]; then
      test_options="$test_options --android_ndk"
    fi
    if [[ $large_test == true ]]; then
        tasks=$((tasks+1))
        test_options="$test_options --large-test"
    fi
    set -x
    docker run -v $PWD/tests:/tests \
      --rm \
      "$full_image_name" \
      sh tests/run_tests.sh $test_options
    set +x
fi

if [[ $deploy == true ]]; then
  tasks=$((tasks+1))
  echo "Deploy image $full_image_name"
  echo "$DOCKERHUB_TOKEN" | docker login --username vincentbrison --password-stdin
  docker push $full_image_name
fi

if [[ $desc == true ]]; then
  echo "Generating image desc.md for $full_image_name"
  docker run -v $PWD/desc:/desc \
    --rm $full_image_name \
    sh desc/desc.sh | tee desc.txt
fi

if [[ $tasks == 0 ]]; then
  echo "No task was executed"
  usage
fi
