#!/bin/sh
image_tag=$1
full_image_name="fabernovel/android:$1"
echo "Full image name = $full_image_name"
container_id=$(cat /etc/hostname)
echo "Container id = $container_id"
ci=${CI:-false}
if [ "$ci" = true ]; then
  echo "Running in CI"
  volume_options="--volumes-from $container_id --workdir $GITHUB_WORKSPACE"
else
  echo "Not running in CI"
  volume_options="-v $PWD:/wd --workdir /wd"
fi

echo "print workspace from docker-android"
set -x
docker run \
  $volume_options \
  --rm $full_image_name \
  ls -a
# TODO run docker with docker-android, then run in it android build test.
