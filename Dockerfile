FROM golang:alpine AS builder
ENV GOCRYPTFS_VERSION v2.5.4

RUN apk add bash gcc git libc-dev openssl-dev
RUN go install github.com/rfjakob/gocryptfs/v2@${GOCRYPTFS_VERSION}

FROM alpine:latest

ENV MOUNT_OPTIONS="-allow_other -nosyslog" \
    UNMOUNT_OPTIONS="-u -z"

COPY --from=builder /go/bin/gocryptfs /usr/local/bin/gocryptfs
RUN apk --no-cache add fuse bash
RUN echo user_allow_other >> /etc/fuse.conf

COPY run.sh run.sh

CMD ["./run.sh"]
