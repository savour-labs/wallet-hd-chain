# Build savour-hd in a stock Go builder container
FROM golang:1.19.5-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers

ADD . /savour-core
RUN cd /savour-hd && build/env.sh go build

# Pull savour-hd into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
RUN mkdir /etc/savour-hd

ARG CONFIG=config.yml

COPY --from=builder /savour-core/savour-core /usr/local/bin/
COPY --from=builder /savour-core/${CONFIG} /etc/savour-core/config.yml

EXPOSE 8888
ENTRYPOINT ["savour-core"]
CMD ["-c", "/etc/savour-core/config.yml"]