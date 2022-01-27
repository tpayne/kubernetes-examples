ArgoCD Samples
==============

This repo has a couple of example Kubernetes deployment YAML files that show how to use ArgoCD.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to
- You have installed `brew` package manager

Running the samples
-------------------
To run the samples, please do the following steps.

First, install ArgoCD...

    ./deployargocd.sh

Install the ArgoCD default sample apps repo and an application using CLI (can do it with UI as well)...

    argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git \
        --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
    argocd app get guestbook

Bring the app just created into synch with the latest repo state by using...

    argocd app sync guestbook

This will run the synchronisation.

    argocd app get guestbook

Cleaning Up
-----------
To clean up the installation, do the following...

    ./deployargocd.sh -d

This will delete all the items created in your Kubernetes installation.

Notes
-----
- These scripts are only for demo purposes and have not been vetted for production use
- The script was developed on Mac and may not work on other OSs
- https://argo-cd.readthedocs.io/en/stable/getting_started/
- https://github.com/argoproj/argocd-example-apps
- https://argo-cd.readthedocs.io/en/stable/
