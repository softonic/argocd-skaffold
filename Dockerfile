ARG ARGOCD_VERSION=2.14.11
FROM quay.io/argoproj/argocd:v${ARGOCD_VERSION}

ARG KUBECTL_VERSION=1.24.4
ARG HELM_VERSION=3.12.1
ARG HELM_SECRETS_VERSION=3.15.0
ARG HELM_OCTOPUS_VERSION=0.2.0
ARG SOPS_VERSION=3.7.3
ARG SKAFFOLD_VERSION=v2.7.1
ARG JQ_VERSION=1.6
ARG CHARTMUSEUM_PASS=""
ARG YQ_VERSION=v4.47.1
ARG YQ_BINARY=yq_linux_amd64

USER root

# Install dependencies
RUN apt-get update \
  && apt-get install -y curl sudo wget python3-pip\
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD helm /usr/local/bin/

# Install binaries
RUN wget -qO- https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm.bin \
    && chmod +x /usr/local/bin/helm.bin \
    && curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux \
    && chmod +x /usr/local/bin/sops \
    && curl -o /usr/local/bin/skaffold -L https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-amd64 \
    && chmod +x /usr/local/bin/skaffold \
    && curl -o /usr/local/bin/skaffold_v2 -L https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION_2}/skaffold-linux-amd64 \
    && chmod +x /usr/local/bin/skaffold_v2 \
    && wget https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -O /usr/bin/jq \
    && chmod +x /usr/bin/jq \
    && wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq \
    && chmod +x /usr/bin/yq \
    && curl -LO https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/

USER 999

# Create the config directory and copy the plugin.yaml file
WORKDIR /home/argocd/cmp-server/config/
COPY plugin.yaml ./

# Install helm secrets and helm octopus
RUN /usr/local/bin/helm.bin plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION} &&\
 /usr/local/bin/helm.bin plugin install https://github.com/softonic/helm-octopus --version ${HELM_OCTOPUS_VERSION}
