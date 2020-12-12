FROM debian:buster-slim

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

RUN apt-get upgrade -yq && \
    apt-get autoremove
