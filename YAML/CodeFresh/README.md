CodeFresh Samples
=================

This repo has a couple of example Kubernetes deployment YAML files that show how to use CodeFresh.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to
- Your Kubernetes system has a NGINX Ingress controller installed. Note - only NGINX is currently supported by CodeFresh
- You have read the pre-requisites documented [here](hhttps://codefresh.io/csdp-docs/docs/runtime/requirements/)
- You will need a CodeFresh token and a Git token

Installing Kubernetes & NGINX Controller
----------------------------------------
If you do not have access to a Kubernetes system with NGINX already installed, then a couple of helper
scripts are provided that can help you with this process.

To install a Kubernetes system (using Azure AKS), then please run this script...

    ./deployk8s.sh

This will install a working Kubernetes server that you can use.

Then, to install an Ingress controller (NGINX) into this K8s installation, then please do...

    ./deploycontroller.sh

This will install NGINX.

Installing CodeFresh
--------------------
To install `CodeFresh`, you can either follow the instructions [here](https://codefresh.io/csdp-docs/docs/runtime/installation/) or run the following script. You will however still need to sign up with CodeFresh and get a CodeFresh
token as this script will not do that for you.

Once you have signed up for CodeFresh and have a CodeFresh token, you can install CodeFresh using the following script.

    ./deploycodefresh.sh -t <codefresh-token> -gt <git-token> -repo <git-repo> 

Where `<codefresh-token>` is the CodeFresh token you have, `<git-token>` is a valid Git Token and `<git-repo>` is an EMPTY Git
repo URL you have created. You can either specify an existing empty repo or a new one (which will get created for you).

This script will install CodeFresh and setup the necessary tokens.

Integrating GitOps Provider
---------------------------
Once you have installed `CodeFresh`, it may be necessary to integrate with a GitOps provider. This can be done via the
following commands...

    brew tap codefresh-io/cli && brew install codefresh
    codefresh install gitops codefresh
    codefresh upgrade gitops argocd-agent

You will need to answer various questions as you run these commands.  


Running the samples
-------------------
TBD

Cleaning Up
-----------
To clean up the installation, do the following...

    ./deploycodefresh.sh -t <codefresh-token> -gt <git-token> -repo <git-repo> -d

This will delete all the items created in your Kubernetes installation.

Notes
-----
- These scripts are only for demo purposes and have not been vetted for production use
- The script was developed on Mac and may not work on other OSs
- https://codefresh.io/docs/docs/getting-started/create-a-basic-pipeline/
- https://g.codefresh.io/projects/
- https://codefresh.io/pricing/
