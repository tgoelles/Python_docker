#/bin/zsh

docker build --platform linux/amd64,linux/arm64 --rm -f "Dockerfile" -t tgoelles/python_base:v0.0.1 "."
