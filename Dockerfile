FROM openresty/openresty:alpine-apk

WORKDIR /opt/nginx-ip/

COPY nginx.conf nginx.conf
COPY ip.lua ip.lua

EXPOSE 80

CMD ["/usr/local/openresty/bin/openresty", "-p", ".", "-c", "nginx.conf"]

LABEL maintainer="Dmitry Meyer <me@undef.im>"
