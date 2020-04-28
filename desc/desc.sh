#!/bin/sh

echo "apt packages:"
apt list --installed
echo

echo "rbenv:"
rbenv -v
echo

echo "Default ruby version:"
ruby -v
echo

echo "Installed gems:"
gem list
echo

echo "gcloud env:"
gcloud --version
echo

echo "Android env:"
sdkmanager --sdk_root=$ANDROID_HOME --list
echo
