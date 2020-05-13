#!/bin/sh
image_tag=$1
exec=$2
full_image_name="fabernovel/android:$image_tag"
echo "Full image name = $full_image_name"

container_id=$(cat /etc/hostname)
echo "Container id = $container_id"
volume_options="--volumes-from $container_id --workdir $GITHUB_WORKSPACE"

set -x
docker run \
  $volume_options \
  -e HOME -e GITHUB_JOB -e GITHUB_REF -e GITHUB_SHA -e GITHUB_REPOSITORY -e GITHUB_REPOSITORY_OWNER -e GITHUB_RUN_ID -e GITHUB_RUN_NUMBER -e GITHUB_ACTOR -e GITHUB_WORKFLOW -e GITHUB_HEAD_REF -e GITHUB_BASE_REF -e GITHUB_EVENT_NAME -e GITHUB_WORKSPACE -e GITHUB_ACTION -e GITHUB_EVENT_PATH -e RUNNER_OS -e RUNNER_TOOL_CACHE -e RUNNER_TEMP -e RUNNER_WORKSPACE -e ACTIONS_RUNTIME_URL -e ACTIONS_RUNTIME_TOKEN -e ACTIONS_CACHE_URL -e GITHUB_ACTIONS=true -e CI=true \
  --rm \
  $full_image_name \
  /bin/sh -c "$exec"
