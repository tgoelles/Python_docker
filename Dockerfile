#-------------------------------------------------------------------------------------------------------------
# Based on a template by  Microsoft Corporation.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
# adapted by Thomas Gölles
#-------------------------------------------------------------------------------------------------------------

FROM continuumio/miniconda3:4.10.3

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ARG PYTHON_VERSION
ENV PYTHON_VERSION=${PYTHON_VERSION}

# Copy environment.yml (if found) to a temp locaition so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
COPY environment$PYTHON_VERSION.yml /tmp/conda-tmp/
COPY .bashrc /root/.bashrc

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get -y install git iproute2 procps iproute2 lsb-release nano less jed \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # JVM
    && mkdir -p /usr/share/man/man1 \
    && apt-get -y install default-jre-headless \
    #
    # to download data
    && apt-get -y install netcat curl make wget \
    #
    # plotly orca
    && apt-get install -y xvfb \
    && apt-get install -y libgtk2.0-0 \
    && apt-get install -y libasound2 \
    && apt-get install -y libxrender1 libxtst6 libxi6 libxss1 libgconf-2-4 libnss3-dev \
    # handy tools
    && apt-get -y install imagemagick imagemagick-doc \
    && apt-get -y install libreoffice --no-install-recommends \
    && apt-get -y install hunspell man bash-completion \
    && apt-get -y install libreoffice-java-common \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Update Python environment based on environment.yml
RUN /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment$PYTHON_VERSION.yml

RUN alias orca="xvfb-run orca"

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=""

ENTRYPOINT ["conda", "activate", "base"]