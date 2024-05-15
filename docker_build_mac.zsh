#/bin/zsh

# just for local testing. Everthing is build wiht github actions

docker build --rm -f "Dockerfile" --build-arg PYTHON_VERSION=3.11 -tghcr.io/tgoelles/python_docker:test "."
