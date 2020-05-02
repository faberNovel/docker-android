# docker-android
![Run test & large tests daily](https://github.com/faberNovel/docker-android/workflows/Run%20test%20&%20large%20tests%20daily/badge.svg?branch=develop)

docker-android is aiming to provide general purpose docker images to run CI steps of Android project.
It should work out of the box on any CI/CD service providing docker support.
CI/CD service status:
| CI/CD service | Tested |
| ------------- | ------ |
| [GitHub Actions](https://help.github.com/en/actions) | ✅ |
| [GitLab CI](https://docs.gitlab.com/ee/ci/docker/using_docker_images.html) | ✅ |
| [Circle CI](https://circleci.com/docs/2.0/executor-types/#using-docker) | 🚧 |
| [Travis CI](https://travis-ci.com/) | 🚧 |


## Usage
docker-android images are hosted on [DockerHub](https://hub.docker.com/repository/docker/fabernovel/android).

We provide stable and snapshot variants for latest Android API levels, including or not native SDK.
We use the following tagging policy:
`API-NDK-VERSION`
* `API` the Android API to use, like `api-28`, `api-29`
* `NDK` is the presence or not of the [Android NDK](https://developer.android.com/ndk) in the image
* `VERSION` is the image version. Check [Versions](https://github.com/faberNovel/docker-android/tree/feature/documentation#versions)

## Versions
* `snapshot` versions are build on each push on `develop` branch
* Release versions `v*` on each [GitHub Release](https://github.com/faberNovel/docker-android/releases)

## Images
Image description is provided as asset with each [GitHub Release](https://github.com/faberNovel/docker-android/releases).

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

You can change image settings via its [Dockerfile](https://github.com/faberNovel/docker-android/blob/feature/documentation/Dockerfile).
You can build, test, and deploy image using [ci_cd.sh](https://github.com/faberNovel/docker-android/blob/feature/documentation/ci_cd.sh) script. You need to install docker first.
```bash
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
