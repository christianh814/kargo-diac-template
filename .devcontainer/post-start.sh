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
freight=$(kargo get freight --project kargo-demo -o jsonpath='{.metadata.name}')
for stage in test uat prod
do
	promotion=$(kargo promote --project kargo-demo --freight ${freight} --stage ${stage} -o jsonpath='{.metadata.name}')
	kubectl wait --for jsonpath='{.status.phase}'=Succeeded promotions.kargo.akuity.io ${promotion} -n kargo-demo --timeout=60s
	kubectl wait --for jsonpath='{.status.currentFreight.name}'=${freight} stages.kargo.akuity.io ${stage} -n kargo-demo --timeout=60s
	## Until we get --wait in promotion we have to do the following: Track https://github.com/akuity/kargo/issues/1888
	promotioncounter=0
	until [[ $(kubectl get freights.kargo.akuity.io -n kargo-demo ${freight} -o jsonpath='{.status.verifiedIn}' | grep -c ${stage}) -ne 0 ]]
	do
		[[ ${promotioncounter} -gt 6 ]] && echo "Promotion took too long to verify" && exit 13
		echo "waiting for promotion to be verified"
		promotioncounter=$((promotioncounter+1))
		sleep 5
	done
done


## Best effort env loading
source ~/.bashrc

## Log it
echo "post-start complete" >> ~/.status.log
