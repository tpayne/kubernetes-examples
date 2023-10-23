# This image is used for running test scripts
FROM alpine:3

# Set up APK repositories and upgrade
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main git \
    && apk -U upgrade
RUN apk add --no-cache ca-certificates && update-ca-certificates
RUN apk add --no-cache coreutils && rm -rf /var/cache/apk/*   \
    && apk add --no-cache openjdk17 tzdata \
    && apk add --no-cache nss \
    && rm -rf /var/cache/apk/*

# Install additional required tools
RUN apk add --no-cache git curl bash zip unzip gradle maven libstdc++ procps

RUN curl -sSLo BrowserStackLocal-alpine.zip \
    "https://www.browserstack.com/browserstack-local/BrowserStackLocal-alpine.zip" \
    && unzip BrowserStackLocal-alpine.zip \
    && rm BrowserStackLocal-alpine.zip \
    && chmod a+rx /BrowserStackLocal \
    && mv /BrowserStackLocal /usr/local/bin

# renovate: datasource=github-releases depName=mikefarah/yq
ENV YQ_VERSION="v4.30.6"
RUN curl -sSLo /usr/bin/yq \
    "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
    && chmod +x /usr/bin/yq

# renovate: datasource=github-releases depName=stedolan/jq extractVersion=^jq-(?<version>.*)$
ENV JQ_VERSION="1.6"
RUN curl -sSLo /usr/bin/jq \
    "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" \
		&& chmod +x /usr/bin/jq

# Install GO for JUNIT processing
# hadolint ignore=DL3022
COPY --from=golang:1.21-alpine /usr/local/go/ /usr/local/go/

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN go install github.com/jstemmer/go-junit-report@latest \
    && go install github.com/alexec/junit2html@latest

ARG account=testusr
RUN addgroup -S ${account} \
    && adduser -S ${account} -G ${account}
USER ${account}:${account}

WORKDIR /scripts

CMD ["/bin/bash"]
