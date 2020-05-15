#!/bin/sh
echo "## Image environment"
grep "DISTRIB_DESCRIPTION=.*$" /etc/*-release | # extract only distrib description
cut -d= -f2 # get distrib description value only

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
ruby -v | cut -d' ' -f2-
echo "### rbenv"
rbenv -v | cut -d' ' -f2-
echo "### Installed gems:"
gem list
echo
