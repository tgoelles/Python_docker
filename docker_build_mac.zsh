#/bin/zsh

# just for local testing. Everthing is build wiht github actions

tag="v0.4.0"

docker build --rm -f "Dockerfile" --build-arg PYTHON_VERSION=3.10 -t tgoelles/python_base:$tag "."
docker run -it tgoelles/python_base:$tag