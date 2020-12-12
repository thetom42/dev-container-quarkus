FROM debian:buster-slim

# Refresh apt package lists & install common packages
RUN apt-get update && \
    apt-get install -yq \
      apt-utils \
      git \
      openssh-client \
      gnupg2 \
      iproute2 \
      procps \
      lsof \
      htop \
      net-tools \
      psmisc \
      curl \
      wget \
      rsync \
      ca-certificates \
      unzip \
      zip \
      nano \
      vim-tiny \
      less \
      jq \
      lsb-release \
      apt-transport-https \
      dialog \
      libc6 \
      libgcc1 \
      libgssapi-krb5-2 \
      libicu[0-9][0-9] \
      liblttng-ust0 \
      libstdc++6 \
      zlib1g \
      locales \
      sudo \
      ncdu \
      man-db \
      strace

RUN curl -sSL "https://get.sdkman.io?rcupdate=false" | bash && \
    chown -R gitpod /usr/local/sdkman && \
    updaterc "export SDKMAN_DIR=/usr/local/sdkman\nsource /usr/local/sdkman/bin/sdkman-init.sh"

RUN su gitpod -c "source usr/local/sdkman/bin/sdkman-init.sh && \
    sdk install java 20.3.0.r11-grl && sdk flush archives && sdk flush temp"

RUN apt-get update && \
    apt-get -yq install build-essential libz-dev zlib1g-dev && \
    export GRAALVM_HOME=/usr/local/sdkman/candidates/java/current && \
    /usr/local/sdkman/candidates/java/current/bin/gu install native-image

RUN apt-get upgrade -yq && \
    apt-get autoremove
