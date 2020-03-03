# Exit immediately if a command returns a non-zero status.
set -e

java -version
rbenv -v
ruby -v

cd ./tests/test-app
gem install --no-document bundler:2.1.4
bundle install
bundle exec fastlane android build

exit 0
