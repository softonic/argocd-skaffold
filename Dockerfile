ARG ARGOCD_VERSION=1.8.7
FROM argoproj/argocd:v${ARGOCD_VERSION}

ARG HELM_VERSION=3.5.1
ARG HELM_SECRETS_VERSION=3.4.1
ARG SOPS_VERSION=3.6.1
ARG SKAFFOLD_VERSION=v1.26.1
ARG YQ_VERSION=2.4.1
USER root

# Install dependencies
RUN apt-get update \ 
  && apt-get install -y curl sudo wget python3-pip\
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD helm /usr/local/bin/

# Install Helm3
RUN wget -qO- https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm.bin \
  && chmod +x /usr/local/bin/helm.bin

# Install recent sops
RUN curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux && chmod +x /usr/local/bin/sops

RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-amd64 && chmod +x skaffold && mv skaffold /usr/local/bin

# yq

RUN pip3 install yq

USER argocd

# Install helm secrets
RUN /usr/local/bin/helm.bin plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION}
