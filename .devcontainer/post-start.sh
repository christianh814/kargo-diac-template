#!/bin/bash

echo "post-start start" >> ~/status.log

# this runs in background each time the container starts

kind export kubeconfig --name kargo-quickstart
source ~/.bashrc

echo "post-start complete" >> ~/status.log
