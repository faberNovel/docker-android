FROM openjdk:8-jdk

MAINTAINER Vincent Brison <vincent.brison@fabernovel.com>

## Setup Bash
# Import bash config
COPY .bash* root/

# Load bash config for non interactive bash
ENV BASH_ENV "~/.bashrc"

# Use bash
SHELL ["/bin/bash", "-l", "-c"]

## Setup apt
RUN apt update -y

## Setup gcloud SDK
RUN apt install -y \
  wget \
  tar

RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

## Setup Android SDK
RUN apt install -y \
  wget \
  unzip

# Setup env
ENV PATH "$PATH:$PWD/.android/platform-tools/"
ENV PATH "$PATH:$PWD/.android/tools/bin"
ENV ANDROID_HOME "$PWD/.android"
ENV ANDROID_COMPILE_SDK "29"
ENV ANDROID_BUILD_TOOLS "29.0.3"

RUN wget --quiet --output-document=/tmp/sdk-tools-linux.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
    && unzip /tmp/sdk-tools-linux.zip -d ${ANDROID_HOME} \
    && rm -rf /tmp/sdk-tools-linux.zip

# Install platform tools and Android SDK for the compile target
RUN ${ANDROID_HOME}/tools/bin/sdkmanager --update
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}"
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}"
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager "extras;google;m2repository"
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "extras;android;m2repository"

## Setup Ruby/Bundler
# Install RVM to get ruby
RUN mkdir ~/.gnupg
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby
ENV PATH "$PATH:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Install rubys envs
# RVM bundled with Ruby 2.6.3. To install additional ruby envs do :
# - rvm install X.Y.Z

# Install bundler
RUN gem install bundler -NV -f

## Clean
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

## Run commands in logged in session, to support RVM
CMD ["bash", "-l"]
