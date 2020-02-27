# exit when any command fails
set -e

java -version
rbenv -v
ruby -v

cd ./tests/test-app
bundle install
bundle exec fastlane android build

exit 0
