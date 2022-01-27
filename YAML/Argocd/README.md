ArgoCD Samples
==============

This repo has a couple of example Kubernetes deployment YAML files that show how to use ArgoCD.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Running the samples
-------------------
To run the samples, please do the following steps.

First, install ArgoCD...

    ./deployargocd.sh

TBD

Cleaning Up
-----------
To clean up the installation, do the following...

    ./deployargocd.sh -d

This will delete all the items created in your Kubernetes installation.

Notes
-----
- These scripts are only for demo purposes and have not been vetted for production use
- https://argo-cd.readthedocs.io/en/stable/getting_started/