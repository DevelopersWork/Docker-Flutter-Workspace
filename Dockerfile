FROM debian:bullseye

ENV DEBIAN_FRONTEND noninteractive

# Prerequisites
RUN apt-get -qq update -y
RUN apt-get -qq install -y git wget curl zip unzip apt-transport-https ca-certificates gnupg

# Add repo for chrome stable
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list

# Add repo for OpenJDK 8 from JFrog.io
RUN wget -q -O - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN echo 'deb [arch=amd64] https://adoptopenjdk.jfrog.io/adoptopenjdk/deb bullseye main' | tee /etc/apt/sources.list.d/adoptopenjdk.list

# Install the dependencies needed for the rest of the build.
RUN apt-get -qq update -y
RUN apt -qq install -y xz-utils libglu1-mesa gcc gdb
RUN apt -qq install -y libgconf-2-4 libstdc++6 fonts-droid-fallback lib32stdc++6 build-essential python3 
RUN apt -qq install -y --no-install-recommends default-jdk-headless adoptopenjdk-8-hotspot
RUN apt -qq install -y --no-install-recommends google-chrome-stable  

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
ENV JAVA_HOME="/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64"
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
RUN wget --progress=dot:giga -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools $ANDROID_SDK_ROOT/tools
ENV PATH "$PATH:$ANDROID_SDK_ROOT/tools/bin"
RUN yes "y" | "sdkmanager" "tools" > /dev/null
RUN yes "y" | "sdkmanager" "build-tools;28.0.3" > /dev/null
RUN yes "y" | "sdkmanager" "platforms;android-30" > /dev/null
RUN yes "y" | "sdkmanager" "platform-tools" > /dev/null
RUN yes "y" | "sdkmanager" "cmdline-tools;latest" > /dev/null
RUN yes "y" | "sdkmanager" "extras;android;m2repository" > /dev/null
RUN yes "y" | "sdkmanager" "extras;google;m2repository" > /dev/null
RUN yes "y" | "sdkmanager" "patcher;v4" > /dev/null
RUN yes | sdkmanager --licenses
ENV PATH "$PATH:$ANDROID_SDK_ROOT/platform-tools"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"

# Run basic check to download Dark SDK
RUN flutter doctor 
RUN flutter config --android-sdk $ANDROID_SDK_ROOT
RUN flutter doctor --android-licenses

# Record the exposed port
ENV FLUTTER_WEB_PORT 5000
EXPOSE $FLUTTER_WEB_PORT

# Enable flutter web
RUN flutter config --enable-web

# Copy files to container and build
COPY --chown=developer:developer web_server.sh /home/developer/server.sh
COPY --chown=developer:developer connect_remote_adb.sh /home/developer/adb.sh

# Install dependencies for desktop flutter run
USER root
RUN apt-get install -y --no-install-recommends clang cmake libgtk-3-dev ninja-build pkg-config x11-xserver-utils xauth xvfb
RUN apt-get upgrade -y --no-install-recommends 
RUN apt-get clean

# Switching back to developer
USER developer
