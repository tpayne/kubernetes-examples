GitOps Deployment Sample
========================

This repo contains an example which shows how to do implement GitOps in Azure Arc.

**To try this sample for real, it is best to fork this repo to your own Github repo so that you can modify files as appropriate.**

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to
- A valid Azure account that allows you to create assets
- You have logged into a (Unix) terminal window that has the `az` client installed

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`.

Running the Example
-------------------
To setup the example, please do the following...

List available regions to you and select a region...

    az account list-locations --query [].name
    az configure --defaults location=<region>
    az config set extension.use_dynamic_install=yes_without_prompt

Create the Kubernetes resources for the demo...

    az provider register --namespace Microsoft.Kubernetes
    az provider register --namespace Microsoft.KubernetesConfiguration
    az provider register --namespace Microsoft.ExtendedLocation
    az group create -n rg_001
    az aks create -n k8gitops -g rg_001
    az aks get-credentials -n k8gitops -g rg_001 --overwrite-existing
    az connectedk8s connect -n k8gitops -g rg_001
    kubectl get deployments,pods -n azure-arc
    az k8s-configuration create --name demo-app \
        --cluster-name k8gitops -g rg_001 \
        --operator-instance-name demo-app \
        --operator-namespace demo-app \
        --repository-url https://github.com/tpayne/kubernetes-examples.git --scope cluster \
        --cluster-type connectedClusters \
        --operator-params '"--git-readonly --git-branch=main --git-poll-interval 30s --git-path=gitops/azurearc/configs/releases/prod"' \
        --enable-helm-operator  \
        --helm-operator-params '--set helm.versions=v3' \
        --ssh-private-key '' --ssh-private-key-file '' --https-user '' --https-key '' \
        --ssh-known-hosts '' --ssh-known-hosts-file ''
    az k8s-configuration show -n demo-app -c k8gitops -g rg_001 --cluster-type connectedClusters
    
This will deploy a canary release to the cluster based on the configuration in the `releases/prod` directory.

Creating Helm Templates
-----------------------
You can create helm templates by...

    cd configs/charts/
    helm create <appName>

You can then test them by...

    helm lint <appName>
    helm template <appName> | kubectl create -f -

Then fix the syntax errors as appropriate

Cleaning Up
-----------
To clean up the installation, do the following...

    kubectl delete all --all -n logicapp-prod && kubectl delete namespace logicapp-prod && \
        az group delete -g rg_001 -y

This will delete all the items created in your Kubernetes installation.

Issues
------
- Arc does not seem to be able to handle mixed case repo directories. Always make them lowercase

Notes
-----
- https://techcommunity.microsoft.com/t5/azure-arc/azure-arc-enabled-kubernetes-with-gitops/ba-p/1654171
- https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-configurations
- https://www.mytechramblings.com/posts/gitops-with-azure-devops-helm-acr-flux-and-k8s/
- https://docs.microsoft.com/en-gb/azure/governance/policy/concepts/policy-for-kubernetes

