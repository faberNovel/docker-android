FROM ubuntu:20.04

## Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime


## Use unicode
RUN apt-get update && apt-get -y install locales && \
    locale-gen en_US.UTF-8 || true
ENV LANG=en_US.UTF-8

## Install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
  openjdk-11-jdk \
  git \
  wget \
  build-essential \
  zlib1g-dev \
  libssl-dev \
  libreadline-dev \
  unzip \
# needed by google cloud sdk
  python

## Clean dependencies
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

## Install rbenv
ENV RBENV_HOME "/root/.rbenv"
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_HOME
ENV PATH "$PATH:$RBENV_HOME/bin"
ENV PATH "$PATH:$RBENV_HOME/shims"

# Install ruby-build (rbenv plugin)
RUN mkdir -p "$RBENV_HOME"/plugins
RUN git clone https://github.com/rbenv/ruby-build.git "$RBENV_HOME"/plugins/ruby-build

# Install default ruby env
RUN echo “install: --no-document” > ~/.gemrc
ENV RUBY_CONFIGURE_OPTS=--disable-install-doc
RUN rbenv install 2.7.0
RUN rbenv global 2.7.0
RUN gem install bundler:2.1.4

# Install Google Cloud CLI
ARG gcloud_url=https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
ARG gcloud_home=/usr/local/gcloud
ARG gcloud_install_script=${gcloud_home}/google-cloud-sdk/install.sh
ARG gcloud_bin=${gcloud_home}/google-cloud-sdk/bin
RUN mkdir -p ${gcloud_home} && \
    wget --quiet --output-document=/tmp/gcloud-sdk.tar.gz ${gcloud_url} && \
    tar -C ${gcloud_home} -xvf /tmp/gcloud-sdk.tar.gz && \
    ${gcloud_install_script}
ENV PATH=${gcloud_bin}:${PATH}

## Install Android SDK
ARG sdk_version=commandlinetools-linux-6200805_latest.zip
ARG android_home=/opt/android/sdk
ARG android_api=android-29
ARG android_build_tools=29.0.3
ARG android_ndk=false
ARG ndk_version=21.0.6113669
ARG cmake=3.10.2.4988404
RUN mkdir -p ${android_home} && \
    wget --quiet --output-document=/tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version} && \
    unzip -q /tmp/${sdk_version} -d ${android_home} && \
    rm /tmp/${sdk_version}

# Set environmental variables
ENV ANDROID_HOME ${android_home}
ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg

RUN yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses
RUN sdkmanager --sdk_root=$ANDROID_HOME --install \
  "platform-tools" \
  "build-tools;${android_build_tools}" \
  "platforms;${android_api}"
RUN if [ "$android_ndk" = true ] ; \
  then \
    echo "Installing Android NDK ($ndk_version, cmake: $cmake)"; \
    sdkmanager --sdk_root="$ANDROID_HOME" --install \
    "ndk;${ndk_version}" \
    "cmake;${cmake}" ; \
  else \
    echo "Skipping NDK installation"; \
  fi
