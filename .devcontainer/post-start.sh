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

## Wait for Freight to be present, we'll break if nothing shows up after 30ish seconds
counter=0
until [[ $(kubectl get freights.kargo.akuity.io --namespace kargo-demo -o go-template='{{len .items}}') -gt 0 ]]
do
	## Stop if something isn't there after 30 seconds or so
	[[ ${counter} -gt 6 ]] && echo "freight took too long to show up" && exit 13
	echo "waiting for freight..."
	counter=$((counter+1))
	sleep 5
done

## Preseed Freight by promoting it
for stage in test uat prod
do
	freight=$(kargo get freight --project kargo-demo -o jsonpath='{.metadata.name}')
	promotion=$(kargo promote --project kargo-demo --freight ${freight} --stage ${stage} -o jsonpath='{.metadata.name}')
	kubectl wait --for jsonpath='{.status.phase}'=Succeeded promotions.kargo.akuity.io ${promotion} -n kargo-demo --timeout=60s
	kubectl wait --for jsonpath='{.status.currentFreight.name}'=${freight} stages.kargo.akuity.io test -n kargo-demo --timeout=60s
done


## Best effort env loading
source ~/.bashrc

## Log it
echo "post-start complete" >> ~/.status.log
