#!/bin/bash

## Install KIND with port mappings

kind create cluster \
  --wait 120s \
  --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kargo-quickstart
nodes:
- extraPortMappings:
  - containerPort: 31443 # Argo CD dashboard
    hostPort: 31443
  - containerPort: 31444 # Kargo dashboard
    hostPort: 31444
  - containerPort: 30081 # test application instance
    hostPort: 30081
  - containerPort: 30082 # UAT application instance
    hostPort: 30082
  - containerPort: 30083 # prod application instance
    hostPort: 30083
  
EOF

## Install Cert Manager and wait
helm install cert-manager cert-manager \
  --repo https://charts.jetstack.io \
  --version 1.11.5 \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

## Install Argo CD but don't wait
helm install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --version 5.51.6 \
  --namespace argocd \
  --create-namespace \
  --set 'configs.secret.argocdServerAdminPassword=$2a$10$5vm8wXaSdbuff0m9l21JdevzXBzJFPCi8sy6OOnpZMAG.fOXL7jvO' \
  --set dex.enabled=false \
  --set notifications.enabled=false \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttp=31443 \
  --set server.extensions.enabled=true \
  --set 'server.extensions.contents[0].name=argo-rollouts' \
  --set 'server.extensions.contents[0].url=https://github.com/argoproj-labs/rollout-extension/releases/download/v0.3.3/extension.tar'

## Install Argo Rollouts but don't wait
helm install argo-rollouts argo-rollouts \
  --repo https://argoproj.github.io/argo-helm \
  --version 2.33.0 \
  --create-namespace \
  --namespace argo-rollouts \

## Install Kargo and wait
helm install kargo \
  oci://ghcr.io/akuity/kargo-charts/kargo \
  --namespace kargo \
  --create-namespace \
  --set api.service.type=NodePort \
  --set api.service.nodePort=31444 \
  --set api.adminAccount.passwordHash='$2a$10$Zrhhie4vLz5ygtVSaif6o.qN36jgs6vjtMBdM6yrU1FOeiAAMMxOm' \
  --set api.adminAccount.tokenSigningKey=iwishtowashmyirishwristwatch \
  --wait

## Wait for Freight to be present, we'll break if nothing shows up after 15ish seconds
counter=0
until [[ $(kubectl get freights.kargo.akuity.io -n kargo-demo -o go-template='{{len .items}}') -gt 0 ]]
do
	## Stop if something isn't there after 15 seconds or so
	[[ ${counter} -gt 3 ]] && echo "freight took too long to show up" && exit 13
	echo "waiting for freight..."
	counter=$((counter+1))
	sleep 3
done

## Preseed Freight by promoting it
for stage in test uat prod
do
	promotion=$(kargo promote --project kargo-demo --freight-alias $(kargo get freight --project kargo-demo --output jsonpath={.alias}) --stage ${stage} -o jsonpath='{.metadata.name}')

	kubectl wait --for jsonpath='{.status.phase}'=Succeeded promotions.kargo.akuity.io ${promotion} -n kargo-demo --timeout=30s
done

## Exit here if no errors were found
exit 0

##
##
