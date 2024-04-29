#!/bin/bash

## Log start
echo "post-create start" >> ~/.status.log

## Install the things
echo "=================" >> ~/.status.log
echo "= Bootstrapping =" >> ~/.status.log
echo "=================" >> ~/.status.log
bash .devcontainer/scripts/bootstrap-workloads.sh | tee -a ~/.status.log

## Update Repo With proper username
bash .devcontainer/scripts/update-repo-for-workshop.sh | tee -a ~/.status.log

## Log things
echo "post-create complete" >> ~/.status.log
echo "--------------------" >> ~/.status.log

##
