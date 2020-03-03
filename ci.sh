# Exit immediately if a command returns a non-zero status.
set -e

# Usage of this script
program_name=$0
function usage {
  echo "usage: $program_name [--android_api 29] [--build] [--test]"
  echo "  --android_api androidVersion Use specific Android version from \`sdkmanager --list\`"
  echo "  --android_ndk                Install Android NDK"
  echo "  --ndk_version <version>      Install a specific Android NDK version from \`sdkmanager --list\`"
  echo "  --build                      Build image"
  echo "  --test                       Test image"
  echo "  --deploy                     Deploy image"
  exit 1
}

# Parameters parsing
android_ndk=false

while true; do
  case "$1" in
    --android_api ) android_api="$2"; shift 2 ;;
    --build ) build=true; shift ;;
    --test ) test=true; shift ;;
    --android_ndk ) android_ndk=true; shift ;;
    --ndk_version ) ndk_version="$2"; shift 2 ;;
    --deploy ) deploy=true; shift ;;
    * ) break ;;
  esac
done

if [[ -z "$android_api" ]]; then
  usage
fi

# Compute image tag
image_name=fabernovel/android:api-$android_api
branch=${GITHUB_REF##*/}
if [[ $deploy == true ]]; then
  if [[ $branch == "develop" ]]; then
    image_name="$image_name-snapshot"
  fi
fi

# CI business
tag="$android_api"
if [[ "$android_ndk" == true ]]; then
  tag="$tag:ndk"
fi
tasks=0
if [[ $build == true ]]; then
  tasks=$((tasks+1))
  echo "Building image $image_name"
  if [[ -n "$ndk_version" ]]; then
    ndk_version_build_arg="--build-arg ndk_version=\"$ndk_version\""
  fi
  set -x
  docker build \
    --build-arg android_api=android-$android_api \
    --build-arg android_ndk="$android_ndk" \
    $ndk_version_build_arg \
    --tag $image_name .
  set +x
fi

if [[ $test == true ]]; then
  tasks=$((tasks+1))
  if [[ "$android_ndk" == true ]]; then
    test_options="--android_ndk"
  fi
  echo "Testing image $image_name"
  set -x
  docker run -v $PWD/tests:/tests \
    --rm $image_name \
    sh tests/run_tests.sh $test_options
  set +x
fi

if [[ $deploy == true ]]; then
  tasks=$((tasks+1))
  echo "Deploy image $image_name"
  echo "$DOCKERHUB_TOKEN" | docker login --username vincentbrison --password-stdin
  docker push $image_name
fi

if [[ $tasks == 0 ]]; then
  echo "No task was executed"
  usage
fi
