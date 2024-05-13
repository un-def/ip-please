project := 'nginx-ip'
version := '6'

_list:
  @just --list

build:
  #!/bin/sh
  if docker image inspect "{{project}}:{{version}}" > /dev/null; then
    echo "{{project}}:{{version}} already exists"
    exit 1
  fi
  docker build --pull --no-cache --force-rm --tag "{{project}}:{{version}}" --tag "{{project}}:latest" .

run:
  openresty -p . -c nginx.conf
