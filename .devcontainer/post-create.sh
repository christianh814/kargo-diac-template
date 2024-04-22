#!/bin/bash

## Log start
echo "post-create start" >> ~/.status.log

## Install the things
###curl -L https://raw.githubusercontent.com/akuity/kargo/main/hack/quickstart/kind.sh | bash
echo "=================" >> ~/.status.log
echo "= Bootstrapping =" >> ~/.status.log
echo "=================" >> ~/.status.log
bash .devcontainer/bootstrap-workloads.sh | tee -a ~/.status.log

## Update Repo With proper username
bash .devcontainer/update-repo-for-workshop.sh | tee -a ~/.status.log

## Log things
echo "post-create complete" >> ~/.status.log
echo "--------------------" >> ~/.status.log

##
