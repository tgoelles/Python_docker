#-------------------------------------------------------------------------------------------------------------
# Based on a template by  Microsoft Corporation.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM continuumio/miniconda3

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Copy environment.yml (if found) to a temp locaition so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
COPY environment.yml* /tmp/conda-tmp/

COPY .bashrc /root/.bashrc

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install git iproute2 procps iproute2 lsb-release\
    #
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    #
    # install the kernel to use with jupyter and some extensions
    && python -m ipykernel install --user --name base \
    && pip install jupyterlab_templates \
    #
    && apt-get -y install netcat curl make wget \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Update Python environment based on environment.yml (if presenet)
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp

# jupyter lab extensions
RUN jupyter labextension install jupyterlab-plotly --no-build \
    # jupyter widgets
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build \
    && jupyter labextension install jupyterlab_templates --no-build \
    # Build extensions (must be done to activate extensions since --no-build is used above)
    # always use --minimize=False inside docker, otherwise it would not build
    && jupyter lab build --minimize=False

# jupyter config and templates extension
COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
RUN jupyter serverextension enable --py jupyterlab_templates

# JVM
RUN apt-get update && \
    mkdir -p /usr/share/man/man1 && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install default-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# installing additional tools
RUN apt-get update \
    && apt-get -y install imagemagick imagemagick-doc \
    && apt-get -y install libreoffice --no-install-recommends \
    && apt-get -y install hunspell man bash-completion\
    && apt-get -y install libreoffice-java-common

# orca: needed to export plots generated with plotly
RUN apt-get update -y \
    && apt-get install -y xvfb \
    && apt-get install -y libgtk2.0-0 \
    && apt-get install -y libasound2 \
    && apt-get install -y libxrender1 libxtst6 libxi6 libxss1 libgconf-2-4 libnss3-dev \
    && conda install -y psutil \
    && alias orca="xvfb-run orca" \
    && conda install -y xlrd


# install docker inside container
# Docker script args, location, and expected SHA - SHA generated on release
RUN apt-get update \
    #
    # Install Docker CE CLI
    && apt-get install -y apt-transport-https ca-certificates curl gnupg2 lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    #
    # Install Docker Compose
    && export LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")') \
    && curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=
