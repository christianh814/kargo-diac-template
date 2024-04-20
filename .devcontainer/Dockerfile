# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/ubuntu/.devcontainer/base.Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:0-ubuntu-22.04

# Select desired version for each tool
ENV ARGOCD_VERSION=v2.10.7
RUN curl -sSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64" \
    && chmod +x /usr/local/bin/argocd

ENV AKUITY_VERSION=v0.12.0
RUN curl -sSL -o /usr/local/bin/akuity "https://dl.akuity.io/akuity-cli/${AKUITY_VERSION}/linux/amd64/akuity" \
    && chmod +x /usr/local/bin/akuity

ENV KIND_VERSION=v0.22.0
RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64 \
    && chmod +x /usr/local/bin/kind

# This should be the same K8s version that kind creates.
ENV KUBECTL_VERSION=v1.29.3
RUN curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl

# https://github.com/kubernetes-sigs/kustomize/releases
ENV KUSTOMIZE_VERSION=v5.4.1
RUN curl -Lo /tmp/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
    && tar -xvf /tmp/kustomize.tar.gz -C /tmp \
    && mv /tmp/kustomize /usr/local/bin/kustomize \
    && chmod +x /usr/local/bin/kustomize

ENV HELM_VERSION=3.14.4
RUN curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    && tar -zxvf "helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    && mv linux-amd64/helm /usr/local/bin/ \
    && rm -rf "helm-v${HELM_VERSION}-linux-amd64.tar.gz" linux-amd64

# This should be the same K8s version that kind creates.
ENV KARGO_VERSION=v0.5.2
RUN curl -Lo /usr/local/bin/kargo "https://github.com/akuity/kargo/releases/download/${KARGO_VERSION}/kargo-linux-amd64" \
    && chmod +x /usr/local/bin/kargo

# Run the things we need
RUN apt update && apt install bash-completion

# Add bash completion and such
RUN echo 'source <(kubectl completion bash)' >> /etc/bash.bashrc
RUN echo 'source <(akuity completion bash)' >> /etc/bash.bashrc
RUN echo 'source <(argocd completion bash)' >> /etc/bash.bashrc
RUN echo 'source <(kustomize completion bash)' >> /etc/bash.bashrc
RUN echo 'source <(kind completion bash)' >> /etc/bash.bashrc
RUN echo 'source <(kargo completion bash)' >> /etc/bash.bashrc
RUN echo 'source <(helm completion bash)' >> /etc/bash.bashrc
RUN echo 'alias k="kubectl"' >> /etc/bash.bashrc
RUN echo 'complete -F __start_kubectl k' >> /etc/bash.bashrc
