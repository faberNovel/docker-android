#!/bin/sh

# Exit immediately if a command returns a non-zero status.
set -e

# Assert we are running in docker
if [ ! -f /.dockerenv ]; then
    exit 1
fi

# Check basic tools
java -version
rbenv -v
adb version
