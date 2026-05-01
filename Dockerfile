FROM ubuntu:12.04

ENV DEBIAN_FRONTEND=noninteractive

# Use old archive packages
RUN sed -i -re 's/([a-z]{2}\.)?archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

# Install tools and requirements to build linux-2.6.32
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-4.4 \
    libncurses5-dev \
    wget \
    xz-utils \
    git \
    module-init-tools \
    cpio \
    flex \
    bison \
    libelf-dev \
    libssl-dev \
    bc \
    make

# Make link to gcc
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.4 100

WORKDIR /kernel
