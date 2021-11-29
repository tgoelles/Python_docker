#/bin/zsh

tag="v0.0.1"

docker build --platform linux/amd64,linux/arm64 --rm -f "Dockerfile" -t tgoelles/python_base:$tag "."
#docker build --rm -f "Dockerfile" -t tgoelles/python_base:$tag "."
#docker push tgoelles/python_base:$tag
