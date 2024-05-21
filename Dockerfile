FROM openresty/openresty:alpine-apk

WORKDIR /opt/nginx-ip/

COPY nginx.conf ip.lua favicon.ico ./

EXPOSE 80

CMD ["/usr/local/openresty/bin/openresty", "-p", ".", "-c", "nginx.conf"]

LABEL maintainer="Dmitry Meyer <me@undef.im>"
