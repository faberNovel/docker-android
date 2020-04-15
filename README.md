# docker-android
docker-android is aiming to provide general purpose docker images to run CI steps of Android project.

## Usage
docker-android images are hosted on [DockerHub](https://hub.docker.com/repository/docker/fabernovel/android).

## Images
Images comes with:
* Last two major Ruby versions
* `rbenv`
* Latestes version of the Google Cloud SDK, it can be used for Firebase Test Lab.
* android api version described by image tag
* android ndk described by image tag

## Versions
* `snapshot` versions are build for each push on `develop` branch
* release versions `v*` for each [GitHub Release](https://github.com/faberNovel/docker-android/releases)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

You can build and test images using `ci_cd.sh` script. You need to install docker first.
```bash
./ci_cd.sh --build --test --android_api 29
```

## License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
