
[![Docker](https://github.com/tgoelles/Python_docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/tgoelles/Python_docker/actions/workflows/docker-publish.yml)

## Info

A miniconda based Python Docker environment. Made with devcontainers and VS Code in mind.

The image is build and pushed automatically to the github container registry with every new version tag.

For a standalone use or a quick test use:

```bash
docker run -it ghcr.io/tgoelles/python_docker:latest_py3.10
```

## Features

* multi architecture: AMD64 and ARM64 (for new Mac chips)
* multi Python versions build
* automatic build with github actions after a new version tag is pushed
* conda and pip packages
* contains handy tools such as imagemagick, hunspell, wget and more
* contains libreoffice to convert office documents inside the container
* using zsh as default shell with powerlevel10k

## Developer Notes

* tag and push the version
* github action builds the image and pushes it to the registry