#!/bin/sh
script_path="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

json="$(cat ${script_path}/images_matrix.json)"

# Github Action ::set-output requires newlines to be escaped
json="${json//'%'/'%25'}"
json="${json//$'\n'/'%0A'}"
json="${json//$'\r'/'%0D'}"

echo "::set-output name=$1::$json"
