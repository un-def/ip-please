ARG VERSION
ARG LISTEN_PORT=80

FROM alpine:latest as builder
ARG VERSION
ARG LISTEN_PORT
WORKDIR /build/
RUN : "${VERSION:?}"
COPY nginx.conf.template ip.lua favicon.ico ./
RUN apk -U add envsubst && \
    envsubst '$LISTEN_PORT' < nginx.conf.template > nginx.conf

FROM openresty/openresty:alpine-apk
ARG VERSION
ARG LISTEN_PORT
WORKDIR /opt/nginx-ip/
COPY --from=builder /build/ ./
EXPOSE ${LISTEN_PORT}
CMD ["/usr/local/openresty/bin/openresty", "-e", "stderr" "-p", ".", "-c", "nginx.conf"]
LABEL maintainer="Dmitry Meyer <me@undef.im>"
LABEL version="${VERSION}"
