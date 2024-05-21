project := 'ip-please'
version := '1'

nginx := 'openresty -e stderr -p . -c nginx.conf'

export LISTEN_PORT := env_var_or_default('LISTEN_PORT', '8080')
export LUA_CODE_CACHE := env_var_or_default('LUA_CODE_CACHE', 'off')

set dotenv-load

_list:
  @just --list

build:
  #!/bin/sh
  if docker image inspect "{{project}}:{{version}}" > /dev/null 2>&1; then
    echo "{{project}}:{{version}} already exists"
    exit 1
  fi
  docker build . \
    --pull --no-cache --force-rm \
    --build-arg="VERSION={{version}}" \
    --tag "{{project}}:{{version}}" --tag "{{project}}:latest"

generate-nginx-conf:
  envsubst '$LISTEN_PORT $LUA_CODE_CACHE' < nginx.conf.template > nginx.conf

run:
  #!/bin/sh
  just generate-nginx-conf
  {{nginx}} &
  while true; do
    inotifywait -q --format '*** %w has been modified, reloading' -e modify nginx.conf.template
    just generate-nginx-conf
    {{nginx}} -s reload
  done
