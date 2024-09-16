#!/bin/bash

## Log it
echo "post-start start" >> ~/.status.log

## Export Kubeconfig 
kind export kubeconfig --name kargo-quickstart

## Kargo, login and create project
kargo login --admin --insecure-skip-tls-verify --password admin https://localhost:31444
kargo create project kargo-demo
kargo create credentials \
    --project=kargo-demo kargo-demo-repo \
    --git --repo-url=https://github.com/${GITHUB_REPOSITORY} \
    --username=${GITHUB_USER} --password=${GITHUB_TOKEN}

## Argo CD, login
argocd login --username admin --password admin --insecure --grpc-web localhost:31443

## Apply Manifests
kubectl apply -k demo-deploy/

## Pre-populate freightline
bash .devcontainer/populate-freightline.sh | tee -a ~/.status.log

## Best effort env loading
source ~/.bashrc

## Log it
echo "post-start complete" >> ~/.status.log
