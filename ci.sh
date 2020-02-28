# Exit immediately if a command returns a non-zero status.
set -e

# Usage of this script
programname=$0
function usage {
    echo "usage: $programname [--android_api android-29] [--build] [--test]"
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

# CI business
tasks=0
if [[ $build == true ]]; then
  tasks=$((tasks+1))
  echo "Building image $android_api"
  set -x
  docker build --build-arg android_api=$android_api --tag $android_api .
  set +x
fi

if [[ $test == true ]]; then
  tasks=$((tasks+1))
  echo "Testing image $android_api"
  set -x
  docker run -v $PWD/tests:/tests --rm $android_api sh tests/run_tests.sh
  set +x
fi

if [[ $tasks == 0 ]]; then
  echo "No task was executed"
  usage
  exit 1
fi
