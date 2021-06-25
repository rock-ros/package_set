FROM ubuntu:18.04

MAINTAINER 2maz "https://github.com/2maz"

## BEGIN BUILD ARGUMENTS
# Arguments for creation of the Docker imaged,
# passed via --build-arg

# Optional arguments
ARG PKG_BRANCH="master"
ENV PKG_BRANCH=${PKG_BRANCH}
## END ARGUMENTS

RUN apt update
RUN apt upgrade -y

ENV DEBIAN_FRONTEND noninteractive
RUN apt install -y gnupg2 ruby ruby-dev wget tzdata lsb locales g++ autotools-dev make curl cmake sudo git python3-dev
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN apt update
RUN apt install -y ros-melodic-ros-base

ENV LANGUAGE=de_DE.UTF-8
ENV LANG=de_DE.UTF-8
ENV LC_ALL=de_DE.UTF-8
ENV SHELL /bin/bash
RUN locale-gen de_DE.UTF-8

RUN echo "Europe/Berlin" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata
RUN dpkg-reconfigure locales

RUN useradd -ms /bin/bash docker
RUN echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER docker
WORKDIR /home/docker

RUN git config --global user.email "rock-users@dfki.de"
RUN git config --global user.name "Rock CI"

RUN wget https://raw.githubusercontent.com/rock-core/autoproj/master/bin/autoproj_bootstrap

RUN mkdir -p /home/docker/rock_test
WORKDIR /home/docker/rock_test
# Use the existing seed configuration
COPY --chown=docker .ci/autoproj-config.yml seed-config.yml
ENV AUTOPROJ_BOOTSTRAP_IGNORE_NONEMPTY_DIR 1
ENV AUTOPROJ_NONINTERACTIVE 1
RUN ruby /home/docker/autoproj_bootstrap git https://github.com/rock-core/buildconf.git branch=master --seed-config=seed-config.yml
RUN sed -i "s#\# - gitorious: rock-ros/package_set#- github: rock-ros/package_set\n     branch: ${PKG_BRANCH}#" autoproj/manifest
RUN sed -i "s#rock\.core#base/orogen/types#g" autoproj/manifest
RUN if [ "$PKG_PULL_REQUEST" = "false" ]; then \
        echo "Using branch: ${PKG_BRANCH}"; \
        echo "overrides:\n  - ${PKG_NAME}:\n    branch: ${PKG_BRANCH}" > autoproj/overrides.yml; \
    fi
RUN echo "Autobuild.displayed_error_line_count = 150" >> autoproj/init.rb
## Update
RUN /bin/bash -c "source /opt/ros/melodic/setup.sh; source env.sh; autoproj update; autoproj osdeps"
