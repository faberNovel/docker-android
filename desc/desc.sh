#!/bin/bash
echo "Apt packages:"
apt list --installed
echo '\n'

echo "Ruby env:"
rbenv -v
ruby -v
gem list
echo '\n'

echo "gcloud env:"
gcloud --version
echo '\n'

echo "Android env:"
sdkmanager --sdk_root=$ANDROID_HOME --list
echo '\n'
