project := 'nginx-ip'
version := '6'

nginx := 'openresty -e stderr -p . -c nginx.conf'

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
  #!/bin/sh
  {{nginx}} &
  while true; do
    inotifywait -q --format '*** %w has been modified, reloading' -e modify nginx.conf
    {{nginx}} -s reload
  done
