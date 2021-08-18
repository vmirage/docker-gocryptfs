FROM golang:alpine AS builder
ENV GOCRYPTFS_VERSION v2.1

RUN apk add bash gcc git libc-dev openssl-dev
RUN go get -d github.com/rfjakob/gocryptfs
WORKDIR src/github.com/rfjakob/gocryptfs

RUN git checkout "$GOCRYPTFS_VERSION"
RUN ./build.bash
RUN mv "$(go env GOPATH)/bin/gocryptfs" /bin/gocryptfs

FROM alpine:latest

ENV MOUNT_OPTIONS="-allow_other -nosyslog" \
    UNMOUNT_OPTIONS="-u -z"

COPY --from=builder /bin/gocryptfs /usr/local/bin/gocryptfs
RUN apk --no-cache add fuse bash
RUN echo user_allow_other >> /etc/fuse.conf

COPY run.sh run.sh

CMD ["./run.sh"]
