ARG ARGOCD_VERSION=2.0.5
FROM argoproj/argocd:v${ARGOCD_VERSION}

ARG HELM_VERSION=3.5.1
ARG HELM_SECRETS_VERSION=3.4.1
ARG SOPS_VERSION=3.6.1
ARG SKAFFOLD_VERSION=v1.26.1
ARG JQ_VERSION=1.6
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
    && wget https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -O /usr/bin/jq \
    && chmod +x /usr/bin/jq \
    && pip3 install yq
    

USER argocd

# Install helm secrets
RUN /usr/local/bin/helm.bin plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION}
