# This image is used for running Argo CLI

FROM alpine:20221110

# Set up APK repositories and upgrade
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main git \
    && apk -U upgrade

# Install required tools
RUN apk add --no-cache git curl bash gzip

# renovate: datasource=github-releases depName=mikefarah/yq
ENV YQ_VERSION="v4.27.2"
RUN curl -sSLo /usr/bin/yq \
    "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
    && chmod +x /usr/bin/yq

# renovate: datasource=github-releases depName=stedolan/jq extractVersion=^jq-(?<version>.*)$
ENV JQ_VERSION="1.6"
RUN curl -sSLo /usr/bin/jq \
    "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" \
		&& chmod +x /usr/bin/jq

WORKDIR /tmp/

ENV ARGO_VERSION="v3.3.6"
RUN curl -sSLo ./argo-linux-amd64.gz \
        "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_VERSION}/argo-linux-amd64.gz" \
		&& gunzip ./argo-linux-amd64.gz \
        && chmod a+rx ./argo-linux-amd64 \
        && mv ./argo-linux-amd64 /usr/local/bin/argo

ENV ARGOCD_VERSION="latest"
RUN curl -sSLo /usr/local/bin/argocd \
        "https://github.com/argoproj/argo-cd/releases/${ARGOCD_VERSION}/download/argocd-linux-amd64" \
        && chmod a+rx /usr/local/bin/argocd

WORKDIR /argo

ARG account=argo
RUN addgroup -S ${account} \
    && adduser -S ${account} -G ${account}
USER ${account}:${account}

CMD ["/bin/bash"]
