GitOps Deployment Sample
========================

This repo contains an example which shows how to do implement GitOps in GCP.

**To try this sample for real, it is best to fork this repo to your own Github repo so that you can modify files as appropriate.**

This sample implements a Cloud Build trigger to do a deployment. The GitHub repo detailed being monitored are: -
* Repo: https://github.com/tpayne/kubernetes-examples.git
* Branch: main
* Repo path: Maven/web8k-example/

So, any changes pushed to `Maven/web8k-example/` will cause a deployment to execute.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to
- A valid GCP account that allows you to create assets
- You have logged into a (Unix) terminal window that has the `gcloud` client installed

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`.

Running the Example
-------------------
To setup the example, please do the following...

    gcloud projects list
    gcloud config set project <projectId>
    gcloud compute zones list
    gcloud config set compute/zone <zone>
    gcloud services enable cloudbuild.googleapis.com

Create the Kubernetes resources for the demo (we will assume "testdemo-311716" is the project and
"europe-west1-d" is the zone to use)...

    ./create_cluster.sh -p "testdemo-311716" -z "europe-west1-d" -c "gitops"
    gcloud container clusters get-credentials gitops --zone europe-west1-d
    kubectl config get-contexts
    kubectl config current-context

This will create a cluster ready for setting up `Cloud Build`.

Defining Cloud Build
--------------------
Unfortunately, `Cloud Build` does not have a CLI, so you will need to define the build definitions by hand.

* Login into https://console.cloud.google.com/cloud-build/
* Select `Trigger` from the left sidebar
* In the `Trigger` dialog select `Create Trigger` and setup the details below
  * Name: `Maven Build`
  * Description: `Maven Build`
  * Event: `Push to a branch`
  * Source: Repository - `Connect to new repository`
    * Connect Repository - `Select Source - GitHub (Cloud Build GitHub App)`
    * Connect Repository - `Authenticate - As a GitHub user (assuming you have one)`
    * Connect Repository - `Select Repo - Select/Edit (https://github.com/tpayne/kubernetes-examples)`
    * Source: `Branch - ^main$`
    * Source: `Included files filter - Maven/web8k-example/**`
  * Configuration: `Cloud Build configuration file`
    * Configuration: `Location - Maven/web8k-example/cloudbuild.yaml`

Then, press `Create trigger`

This should then build the repo image and save it to your project. 

**The `cloudbuild.yaml` file is hardcoded for the cluster name and location, so you might need to resolve this with other variables.**

Cleaning Up
-----------
To clean up the installation, do the following...

    ./create_cluster -p "testdemo-311716" -z "europe-west1-d" -c "gitops" --clean-up

This will delete all your Kubernetes installation.

Issues
------
- You may need to enable permission as documented - https://cloud.google.com/build/docs/deploying-builds/deploy-gke

Notes
-----
- https://cloud.google.com/build/docs/deploying-builds/deploy-gke
- https://cloud.google.com/build/docs/building/build-java

