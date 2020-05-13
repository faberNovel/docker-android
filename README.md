# docker-android
![docker-android](logo.png)

![Run test & large tests daily](https://github.com/faberNovel/docker-android/workflows/Run%20test%20&%20large%20tests%20daily/badge.svg?branch=develop)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-green.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Release](https://img.shields.io/github/v/release/fabernovel/docker-android)


docker-android provides general purpose docker images to run CI steps of Android project.
Docker allows you to provide a replicable environment, which does not change with the host machine or the CI service.
It should work out of the box on any CI/CD service providing docker support.
The image is providing standard tools to build and test Android application:
* Android SDK (optionally Android NDK)
* Default Ruby env through [rbenv](https://github.com/rbenv/rbenv) (for [Fastlane](https://fastlane.tools/) for instance)
* Java JDK
* Google Cloud CLI, to support [Firebase Test Lab](https://firebase.google.com/docs/test-lab)

## CI/CD service support
| CI/CD service | Tested |
| ------------- | ------ |
| [GitHub Actions](https://help.github.com/en/actions) | ✅ |
| [GitLab CI](https://docs.gitlab.com/ee/ci/docker/using_docker_images.html) | ✅ |
| [Circle CI](https://circleci.com/docs/2.0/executor-types/#using-docker) | 🚧 |
| [Travis CI](https://travis-ci.com/) | 🚧 |

## 🐙 GitHub Workflow Sample
Github workflows can run inside Docker images using `container` attribute after `runs-on`:
```yml
name: GitHub Action sample

on:
  push:
    branches:
      - develop

jobs:
  build_test_and_deploy:
    runs-on: ubuntu-18.04 # Works also with self hosted runner supporting docker
    container:
      image: docker://fabernovel/android:api-29-v1.0.0

  steps:
    - name: Checkout
      uses: actions/checkout@v2.1.0

    - name: Ruby cache
      uses: actions/cache@v1.1.2
      with:
        path: vendor/bundle
        key: ${{ runner.os }}-gems-${{ hashFiles('**/Gemfile.lock') }}
        restore-keys: |
          ${{ runner.os }}-gems-

    - name: Gradle cache
      uses: actions/cache@v1.1.2
      with:
        path: /root/.gradle
        key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle') }}
        restore-keys: |
          ${{ runner.os }}-gradle

    - name: Bundle install
      run: |
        bundle config path vendor/bundle
        bundle check || bundle install

    - name: Fastlane
      run: bundle exec fastlane my_lane

    - name: Cache workaround # https://github.com/actions/cache/issues/133
      run: chmod -R a+rwx .
```
You can also use the provided Github Action:
```
name: GitHub Action sample

on:
  push:
    branches:
      - develop

jobs:
  build_test_and_deploy:
    runs-on: ubuntu-18.04 # Works also with self hosted runner supporting docker
    container:
        image: docker://docker:stable-git

  steps:
    - name: Checkout
      uses: actions/checkout@v2.1.0

    - name: Test action
      uses: fabernovel/docker-android
      id: docker-android-action
      with:
        exec: |
          bundle install;
          bundle exec fastlane my_lane
```

## 📦 Container Registry
docker-android images are hosted on [DockerHub](https://hub.docker.com/repository/docker/fabernovel/android).

## 🔤 Naming
We provide stable and snapshot variants for latest Android API levels, including or not native SDK.
We use the following tagging policy:
`API-NDK-VERSION`
* `API` the Android API to use, like `api-28`, `api-29`
* `NDK` is the presence or not of the [Android NDK](https://developer.android.com/ndk) in the image
* `VERSION` is the image version. Check [Versions](https://github.com/faberNovel/docker-android/tree/master#versions)

## 🔢 Versions
* `snapshot` versions are build on each push on `develop` branch
* Release versions `v*` on each [GitHub Release](https://github.com/faberNovel/docker-android/releases)

## 📝 Image description
Image description (software and their versions) is provided as asset with each [GitHub Release](https://github.com/faberNovel/docker-android/releases).

## ✏️ Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

You can change image settings via its [Dockerfile](https://github.com/faberNovel/docker-android/blob/master/Dockerfile).
You can build, test, and deploy image using [ci_cd.sh](https://github.com/faberNovel/docker-android/blob/master/ci_cd.sh) script. You need to install docker first.
All scripts must be POSIX compliants.
```sh
usage: ./ci_cd.sh [--android-api 29] [--build] [--test]
  --android-api <androidVersion> Use specific Android version from `sdkmanager --list`
  --android-ndk                  Install Android NDK
  --ndk-version <version>        Install a specific Android NDK version from `sdkmanager --list`
  --build                        Build image
  --test                         Test image
  --deploy                       Deploy image
```

## License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
