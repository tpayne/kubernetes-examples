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

Installing custom samples
-------------------------
The following instructions can be used to install samples from this repo that will also work with ArgoCD and show more complex cases.

Standard K8s sample(s)

    argocd app create canarydeploy --repo https://github.com/tpayne/kubernetes-examples \
        --path YAML/CanaryDeployments --dest-server https://kubernetes.default.svc
    argocd app get canarydeploy
    argocd app sync canarydeploy
    argocd app get canarydeploy
    open "`argocd app get canarydeploy | grep URL: | awk '{print $2}'`"
    argocd app delete canarydeploy -y 
    argocd app list

    argocd app create daemonsets --repo https://github.com/tpayne/kubernetes-examples \
        --path YAML/DaemonSets --dest-server https://kubernetes.default.svc
    argocd app get daemonsets
    argocd app sync daemonsets
    argocd app get daemonsets
    open "`argocd app get daemonsets | grep URL: | awk '{print $2}'`"
    argocd app delete daemonsets -y 
    argocd app list

Helm charts sample(s)

    argocd app create canarydeploy-helm --repo https://github.com/tpayne/kubernetes-examples \
        --path Helm/canary-deployment --dest-server https://kubernetes.default.svc
    argocd app get canarydeploy-helm
    argocd app sync canarydeploy-helm
    argocd app get canarydeploy-helm
    open "`argocd app get canarydeploy-helm | grep URL: | awk '{print $2}'`"
    argocd app delete canarydeploy-helm -y 
    argocd app list

    argocd app create standard3tier-helm --repo https://github.com/tpayne/kubernetes-examples \
        --path Helm/standard3tier-deployment --dest-server https://kubernetes.default.svc
    argocd app get standard3tier-helm
    argocd app sync standard3tier-helm
    argocd app get standard3tier-helm
    open "`argocd app get standard3tier-helm | grep URL: | awk '{print $2}'`"
    argocd app delete standard3tier-helm -y 
    argocd app list

Kustomization sample(s)

    argocd app create postgress-kust --repo https://github.com/tpayne/kubernetes-examples \
        --path YAML/use-cases/postgres --dest-server https://kubernetes.default.svc
    argocd app get postgress-kust
    argocd app sync postgress-kust
    argocd app get postgress-kust
    open "`argocd app get postgress-kust | grep URL: | awk '{print $2}'`"
    argocd app delete postgress-kust -y 
    argocd app list

    argocd app create standard3tier-kust --repo https://github.com/tpayne/kubernetes-examples \
        --path YAML/use-cases/standard3tier --dest-server https://kubernetes.default.svc
    argocd app get standard3tier-kust
    argocd app sync standard3tier-kust
    argocd app get standard3tier-kust
    open "`argocd app get standard3tier-kust | grep URL: | awk '{print $2}'`"
    argocd app delete standard3tier-kust -y 
    argocd app list

The standard 3 tier sample should give you a deployment that looks something like this...

>![Standard 3 tier](https://github.com/tpayne/kubernetes-examples/blob/main/YAML/Argocd/images/ExampleDeployment.png)

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
- https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/
