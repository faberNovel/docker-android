# exit when any command fails
set -e

java -version
rbenv -v
ruby -v

cd ./tests/test-app
./gradlew app:assemble

exit 0
