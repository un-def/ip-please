set dotenv-load

export LISTEN_PORT := env('LISTEN_PORT', '8080')
export LUA_CODE_CACHE := env('LUA_CODE_CACHE', 'off')

nginx := 'openresty -e stderr -p . -c nginx.conf'

run:
  #!/bin/sh
  just generate-nginx-conf
  {{nginx}} &
  while true; do
    inotifywait -q --format '*** %w has been modified, reloading' -e modify nginx.conf.template
    just generate-nginx-conf
    {{nginx}} -s reload
  done

generate-nginx-conf:
  envsubst '$LISTEN_PORT $LUA_CODE_CACHE' < nginx.conf.template > nginx.conf

[default]
_list:
  @just --list --unsorted
