#!/bin/bash

## Log start
echo "post-create start" >> ~/.status.log

## Install the things
curl -L https://raw.githubusercontent.com/akuity/kargo/main/hack/quickstart/kind.sh | bash

## Set up some nice bash completion

cat <<EOC >> /home/vscode/.bashrc
source <(kubectl completion bash)
source <(akuity completion bash)
source <(argocd completion bash)
source <(kustomize completion bash)
source <(kind completion bash)
source <(kargo completion bash)
source <(helm completion bash)
alias k="kubectl"
complete -F __start_kubectl k
EOC

chown $(id -u):$(id -g) /home/vscode/.bashrc
chmod 0644 /home/vscode/.bashrc

## Update Repo With proper username
############## bash .devcontainer/update-repo-for-workshop.sh

## Log things
echo "post-create complete" >> ~/.status.log
echo "--------------------" >> ~/.status.log

##
