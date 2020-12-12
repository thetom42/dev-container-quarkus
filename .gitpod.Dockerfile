#FROM mcr.microsoft.com/vscode/devcontainers/base:buster
FROM debian:buster-slim

# General Options
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="true"
ARG USERNAME=gitpod
ARG USER_UID="automatic"
ARG USER_GID=$USER_UID

# Docker Options
#ARG ENABLE_NONROOT_DOCKER="true"
#ARG SOURCE_SOCKET=/var/run/docker-host.sock
#ARG TARGET_SOCKET=/var/run/docker.sock

# Java Options
ARG INSTALL_JAVA="true"
ARG JAVA_VERSION="20.3.0.r11-grl"

# Maven Options
ARG INSTALL_MAVEN="true"
ARG MAVEN_VERSION="3.6.2"

# Gradle Options
ARG INSTALL_GRADLE="false"
ARG GRADLE_VERSION=""

# Node.js Options
ARG INSTALL_NODE="false"
ARG NODE_VERSION="lts/*"

# Copy all install scripts
ARG NONROOT_USER=gitpod
COPY .devcontainer/library-scripts/*.sh /tmp/library-scripts/

# Refresh apt package lists & install common packages
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}"

# Install Docker CE CLI
#RUN /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${SOURCE_SOCKET}" "${TARGET_SOCKET}" "${USERNAME}"

# Install kubectl & Helm
#RUN bash /tmp/library-scripts/kubectl-helm-debian.sh

# Script copies localhost's ~/.kube/config file into the container and swaps out 
# localhost for host.docker.internal on bash/zsh start to keep them in sync.
#COPY copy-kube-config.sh /usr/local/share/
#RUN chown ${USERNAME}:root /usr/local/share/copy-kube-config.sh
#    && echo "source /usr/local/share/copy-kube-config.sh" | tee -a /root/.bashrc /root/.zshrc /home/${USERNAME}/.bashrc >> /home/${USERNAME}/.zshrc

# Default to root only access to the Docker socket, set up non-root init script
#RUN touch /var/run/docker.socket \
#    && ln -s /var/run/docker.socket /var/run/docker-host.socket \
#    && apt-get -y install socat

# Create docker-init.sh to spin up socat
#RUN echo "#!/bin/sh\n\
#    sudo rm -rf /var/run/docker-host.socket\n\
#    ((sudo socat UNIX-LISTEN:/var/run/docker.socket,fork,mode=660,user=${NONROOT_USER} UNIX-CONNECT:/var/run/docker-host.socket) 2>&1 >> /tmp/vscr-dind-socat.log) & > /dev/null\n\
#    \"\$@\"" >> /usr/local/share/docker-init.sh \
#    && chmod +x /usr/local/share/docker-init.sh

# Install Java, Maven, Gradle
ENV SDKMAN_DIR="/usr/local/sdkman"
ENV PATH="${PATH}:${SDKMAN_DIR}/java/current/bin:${SDKMAN_DIR}/maven/current/bin:${SDKMAN_DIR}/gradle/current/bin"
RUN bash /tmp/library-scripts/java-debian.sh "${JAVA_VERSION:-lts}" "${SDKMAN_DIR}" "${USERNAME}" "true" \
    && if [ "${INSTALL_MAVEN}" = "true" ]; then bash /tmp/library-scripts/maven-debian.sh "${MAVEN_VERSION:-latest}" "${SDKMAN_DIR}" ${USERNAME} "true"; fi \
    && if [ "${INSTALL_GRADLE}" = "true" ]; then bash /tmp/library-scripts/gradle-debian.sh "${GRADLE_VERSION:-latest}" "${SDKMAN_DIR}" ${USERNAME} "true"; fi

# Install Node
#ENV NVM_DIR=/usr/local/share/nvm
#ENV NVM_SYMLINK_CURRENT=true \
#    PATH="${NVM_DIR}/current/bin:${PATH}"
#RUN if [ "$INSTALL_NODE" = "true" ]; then bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}"; fi

# Clean up
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

USER ${NONROOT_USER}

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to
# the Docker socket if "overrideCommand": false is set in devcontainer.json.
# The script will also execute CMD if you need to alter startup behaviors.
#ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
#CMD [ "sleep", "infinity" ]
ENTRYPOINT []