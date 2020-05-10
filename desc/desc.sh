#!/bin/sh
echo "## Image environment"
cat /etc/*-release
echo
echo "## Android environment"
echo "### Android SDKs"
sdkmanager --list --sdk_root=$ANDROID_HOME |
    awk '/Installed packages:/{flag=1; next} /Available Packages/{flag=0} flag'
echo "### Google Cloud SDK"
gcloud --version
echo

echo "## APT packages"
dpkg -l
echo

echo "## Ruby environment"
echo "### Default ruby version"
ruby -v
echo "### rbenv"
rbenv -v
echo "### Installed gems:"
gem list
echo
