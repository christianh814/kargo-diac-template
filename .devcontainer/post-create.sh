#!/bin/bash

## Log start
echo "post-create start" >> ~/.status.log

## Install the things
curl -L https://raw.githubusercontent.com/akuity/kargo/main/hack/quickstart/kind.sh | bash

## Update Repo With proper username
bash .devcontainer/update-repo-for-workshop.sh

## Log things
echo "post-create complete" >> ~/.status.log
echo "--------------------" >> ~/.status.log

##
