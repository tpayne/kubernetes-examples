# This image is used for running Argo CLI

FROM alpine:3

# Set up APK repositories and upgrade
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main git \
    && apk -U upgrade

# Install required tools
RUN apk add --no-cache git curl bash gzip

# Install Terraform
ENV TF_VERSION="1.3.9"
RUN wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
RUN unzip terraform_${TF_VERSION}_linux_amd64.zip && rm terraform_${TF_VERSION}_linux_amd64.zip
RUN mv terraform /usr/bin/terraform && chmod a+rx /usr/bin/terraform

# Install Kubectl
ENV K8S_VERSION="v1.26.2"
RUN curl -sSLo /usr/bin/kubectl \
    https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl \
    && chmod a+rx /usr/bin/kubectl

# renovate: datasource=github-releases depName=mikefarah/yq
ENV YQ_VERSION="v4.27.2"
RUN curl -sSLo /usr/bin/yq \
    "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
    && chmod a+rx /usr/bin/yq

# renovate: datasource=github-releases depName=stedolan/jq extractVersion=^jq-(?<version>.*)$
ENV JQ_VERSION="1.6"
RUN curl -sSLo /usr/bin/jq \
    "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" \
		&& chmod a+rx /usr/bin/jq

WORKDIR /tools

ARG account=tools
RUN addgroup -S ${account} \
    && adduser -S ${account} -G ${account}
USER ${account}:${account}

CMD ["/bin/bash"]
