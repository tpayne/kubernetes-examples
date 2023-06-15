# This image is used for running cd-promote pipeline shell commands

FROM alpine:3

# Set up APK repositories and upgrade
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main \
    && apk -U upgrade

# Install required tools
RUN apk add --no-cache postgresql15-client

ARG account=pgclient
RUN addgroup -S ${account} \
    && adduser -S ${account} -G ${account}
USER ${account}:${account}

CMD ["/bin/bash"]
