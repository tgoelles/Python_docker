#-------------------------------------------------------------------------------------------------------------
# Based on a template by  Microsoft Corporation.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
# adapted by Thomas Gölles
#-------------------------------------------------------------------------------------------------------------

FROM continuumio/miniconda3:latest

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID


# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get -y install locales build-essential git zsh\
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # to download data
    && apt-get -y install netcat curl wget unzip\
    #
    # handy tools
    && apt-get -y install imagemagick imagemagick-doc hunspell man\
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install conda environment from file
ARG PYTHON_VERSION
ENV PYTHON_VERSION=${PYTHON_VERSION}



# allow to conver pdf with imagmagick
RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml

# install tinytex
RUN  /usr/bin/wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh

# texliveonfly
RUN /usr/bin/wget -qP /tmp http://mirrors.ctan.org/support/texliveonfly.zip \
    && unzip -d /tmp /tmp/texliveonfly.zip \
    && mv /tmp/texliveonfly/texliveonfly.py ~/bin/texliveonfly \
    && chmod +x ~/bin/texliveonfly

RUN mv ~/bin /usr/local/bin/latex

# prepend conda environment to path
ENV PATH $CONDA_DIR/envs/${conda_env}/bin:$PATH

# setup Zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/romkatv/powerlevel10k \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

ENV SHELL /bin/zsh

# zsh config
COPY .zshrc /root/.zshrc
COPY .p10k.zsh /tmp/root-code-zsh/.p10k.zsh

# addding conda environment
COPY environment$PYTHON_VERSION.yml /tmp/conda-tmp/environment$PYTHON_VERSION.yml
# HACK due to conda bug
RUN /opt/conda/bin/conda update conda

RUN /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment$PYTHON_VERSION.yml

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=""

ENTRYPOINT [ "/bin/zsh", "-l"]