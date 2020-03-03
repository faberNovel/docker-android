# Exit immediately if a command returns a non-zero status.
set -e

# Usage of this script
program_name=$0
function usage {
    echo "usage: $program_name [--android_api 29] [--build] [--test]"
    echo "  --android_api androidVersion Use specific Android version from \`sdkmanager --list\`"
    echo "  --build                      Build image"
    echo "  --test                       Test image"
    exit 1
}

# Parameters parsing
OPTS=`getopt --long android_api,build,test: -n 'parse-options' -- "$@"`

while true; do
  case "$1" in
    --android_api ) android_api="$2"; shift 2 ;;
    --build ) build=true; shift ;;
    --test ) test=true; shift ;;
    * ) break ;;
  esac
done

if [[ -z "$android_api" ]]; then
  usage
  exit 1
fi

image_name=android:api-$android_api

# CI business
tasks=0
if [[ $build == true ]]; then
  tasks=$((tasks+1))
  echo "Building image $image_name"
  set -x
  docker build --build-arg android_api=android-$android_api --tag $image_name .
  set +x
fi

if [[ $test == true ]]; then
  tasks=$((tasks+1))
  echo "Testing image $image_name"
  set -x
  docker run -v $PWD/tests:/tests --rm $image_name sh tests/run_tests.sh
  set +x
fi

if [[ $tasks == 0 ]]; then
  echo "No task was executed"
  usage
  exit 1
fi
