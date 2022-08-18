# Build Gcnc in a stock Go builder container
FROM golang:1.12-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

ADD . /go-clanetdiuma
RUN cd /go-clanetdiuma && make gcnc

# Pull Gcnc into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-clanetdiuma/build/bin/gcnc /usr/local/bin/

EXPOSE 9196 9197 35410 35410/udp
ENTRYPOINT ["gcnc"]
