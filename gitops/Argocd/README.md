ArgoCD Samples
==============

This repo has a couple of example Kubernetes deployment YAML files that show how to use ArgoCD.

To understand what ArgoCD does, then please refer to the following article. It describes what ArgoCD is and what cases
it should be used in. Essentially, it is a GitOps tool running on top of Kubernetes.

https://argo-cd.readthedocs.io/en/stable/getting_started/

The deployments used in this example are described in the launch page of this main repo.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to
- You have installed `brew` package manager

Running the ArgoCD samples
--------------------------
To run the samples, please do the following steps.

First, install ArgoCD...

    ./deployargocd.sh

Install the ArgoCD default sample apps repo and an application using CLI (can do it with UI as well)...

    argocd app create guestbook \
        --repo https://github.com/argoproj/argocd-example-apps.git \
        --path guestbook \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace default
    argocd app get guestbook

Bring the app just created into synch with the latest repo state by using...

    argocd app sync guestbook

This will run the synchronisation.

    argocd app get guestbook

Installing ArgoCD custom samples
--------------------------------
The following instructions can be used to install samples from this repo that will also work with ArgoCD and show more complex cases.

Standard K8s sample(s)

    argocd app create canarydeploy \
        --repo https://github.com/tpayne/kubernetes-examples \
        --path YAML/CanaryDeployments \
        --dest-server https://kubernetes.default.svc
    argocd app get canarydeploy
    argocd app sync canarydeploy
    argocd app get canarydeploy
    open "`argocd app get canarydeploy | grep URL: | awk '{print $2}'`"
    argocd app delete canarydeploy -y 
    argocd app list

    argocd app create daemonsets \
        --repo https://github.com/tpayne/kubernetes-examples \
        --path YAML/DaemonSets \
        --dest-server https://kubernetes.default.svc
    argocd app get daemonsets
    argocd app sync daemonsets
    argocd app get daemonsets
    open "`argocd app get daemonsets | grep URL: | awk '{print $2}'`"
    argocd app delete daemonsets -y 
    argocd app list

Helm charts sample(s)

    argocd app create canarydeploy-helm \
        --repo https://github.com/tpayne/kubernetes-examples \
        --path Helm/canary-deployment \
        --dest-server https://kubernetes.default.svc
    argocd app get canarydeploy-helm
    argocd app sync canarydeploy-helm
    argocd app get canarydeploy-helm
    open "`argocd app get canarydeploy-helm | grep URL: | awk '{print $2}'`"
    argocd app delete canarydeploy-helm -y 
    argocd app list

    argocd app create standard3tier-helm \
        --repo https://github.com/tpayne/kubernetes-examples \
        --path Helm/standard3tier-deployment \
        --dest-server https://kubernetes.default.svc
    argocd app get standard3tier-helm
    argocd app sync standard3tier-helm
    argocd app get standard3tier-helm
    open "`argocd app get standard3tier-helm | grep URL: | awk '{print $2}'`"
    argocd app delete standard3tier-helm -y 
    argocd app list

Helm pipeline sample(s)

This example also shows how to use aliasing to deploy the same chart 1..N times and how to make
your code DRY compatible.

Check syntax with...

    cd examples/simple
    kubectl apply -n argocd -f argocd/dev/app.pipeline.yaml --dry-run=client
    kubectl apply -n argocd -f argocd/qa/app.pipeline.yaml --dry-run=client
    kubectl apply -n argocd -f argocd/sit/app.pipeline.yaml --dry-run=client
    kubectl apply -n argocd -f argocd/preprod/app.pipeline.yaml --dry-run=client
    kubectl apply -n argocd -f argocd/prod/app.pipeline.yaml --dry-run=client

Run with...

    # Safetly ignore...
    cd examples/simple
    argocd app delete pipeline-dev -y 
    argocd app delete pipeline-qa -y 
    argocd app delete pipeline-sit -y 
    argocd app delete pipeline-preprod -y
    argocd app delete pipeline-prod -y

    kubectl apply -n argocd -f argocd/dev/app.pipeline.yaml
    argocd app get pipeline-dev
    argocd app sync pipeline-dev
    argocd app get pipeline-dev
    sleep 90
    kubectl get all -n dev
    
    kubectl apply -n argocd -f argocd/qa/app.pipeline.yaml
    argocd app get pipeline-qa
    argocd app sync pipeline-qa
    argocd app get pipeline-qa
    sleep 90
    kubectl get all -n qa

    kubectl apply -n argocd -f argocd/sit/app.pipeline.yaml
    argocd app get pipeline-sit
    argocd app sync pipeline-sit
    argocd app get pipeline-sit
    sleep 90
    kubectl get all -n sit

    kubectl apply -n argocd -f argocd/preprod/app.pipeline.yaml
    argocd app get pipeline-preprod
    argocd app sync pipeline-preprod
    argocd app get pipeline-preprod
    sleep 90
    kubectl get all -n preprod

    kubectl apply -n argocd -f argocd/prod/app.pipeline.yaml
    argocd app get pipeline-prod
    argocd app sync pipeline-prod
    argocd app get pipeline-prod
    sleep 90
    kubectl get all -n prod

    open "`argocd app get pipeline-dev | grep URL: | awk '{print $2}'`"
    open "`argocd app get pipeline-qa | grep URL: | awk '{print $2}'`"
    open "`argocd app get pipeline-sit | grep URL: | awk '{print $2}'`"
    open "`argocd app get pipeline-preprod | grep URL: | awk '{print $2}'`"
    open "`argocd app get pipeline-prod | grep URL: | awk '{print $2}'`"

    argocd app delete pipeline-dev -y 
    argocd app delete pipeline-qa -y 
    argocd app delete pipeline-sit -y 
    argocd app delete pipeline-preprod -y
    argocd app delete pipeline-prod -y

    argocd app list

Kustomization sample(s)

    argocd app create postgress-kust \
        --repo https://github.com/tpayne/kubernetes-examples \
        --path YAML/use-cases/postgres \
        --dest-server https://kubernetes.default.svc
    argocd app get postgress-kust
    argocd app sync postgress-kust
    argocd app get postgress-kust
    open "`argocd app get postgress-kust | grep URL: | awk '{print $2}'`"
    argocd app delete postgress-kust -y 
    argocd app list

    argocd app create standard3tier-kust \
        --repo https://github.com/tpayne/kubernetes-examples \
        --path YAML/use-cases/standard3tier \
        --dest-server https://kubernetes.default.svc
    argocd app get standard3tier-kust
    argocd app sync standard3tier-kust
    argocd app get standard3tier-kust
    open "`argocd app get standard3tier-kust | grep URL: | awk '{print $2}'`"
    argocd app delete standard3tier-kust -y 
    argocd app list

The standard 3 tier sample should give you a deployment that looks something like this...

>![Standard 3 tier](https://github.com/tpayne/kubernetes-examples/blob/main/gitops/Argocd/images/ExampleDeployment.png)

Running Argo Workflow samples
-----------------------------
To install a standard sample Argo Workflow, you can do...

    argo submit -n argo --watch \
        https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml

To review the list of workflows you have you can use...

    argo list -n argo

To review the output of workflows you can use...

    argo get -n argo @latest
    argo logs -n argo @latest

To delete a workflow you can use...

    argo delete 

To run the UI you can use...

    argo server --auth-mode server

Depending on where you have you workflow and events namespaced.

You can monitor progress of job related events etc. with...

    kubectl get events -n argo --watch

Running Advanced Argo Workflow samples
--------------------------------------
To run the CI/CD samples, you will need to first install the samples project and pipeline manifests.

You will also need to have the following Argo components installed in your namespace: -
- Argo events
- Argo workflows
- ArgoCD
- An Autopilot repo is provided "github.com/tpayne/argocd-autopilot" that will do this for you

This example assumes that you have installed the namespace from "github.com/tpayne/argocd-autopilot".
As such, you may need to adjust the demo as appropriate.

However, before you do this you will need to modify the host alias used for
ingress access.

```console
    workflows/generic/monitoredRepos/gitops-deploy.event-source.yaml
    workflows/generic/monitoredRepos/gitops-deploy-workflow-templates.ingress.yaml
```

Once the above files are modified and committed to the repo, you can then run the following.

```console
    # Start up argocd if needed - https://localhost:8080/
    kubectl port-forward -n argocd svc/argocd-server 8080:80
    
    # Start up the argo workflow gui if needed - https://localhost:2746/
    argo server -n argocd --auth-mode=server -k --namespaced --loglevel=warn
```

```console
    cd examples/simple
    kubectl delete -n argocd -f workflows/monitor-app.yaml
    kubectl apply -n argocd -f workflows/monitor-app.yaml
    argocd account generate-token --account argorunner
    export ARGOCD_TOKEN=<yourArgoCdToken>
    kubectl create secret \
      generic argocd-token \
      --from-literal=token=${ARGOCD_TOKEN} \
      --dry-run=client \
      --save-config -o yaml | kubectl apply -f - -n argocd
    kubectl create secret \
      generic github-token \
      --from-literal=token=<PAT> \
      --from-literal=user=<ghuser> \
      --from-literal=email=<ghemail> \
      --dry-run=client \
      --save-config -o yaml | kubectl apply -f - -n argocd    
```

Running Argo Workflow samples
-----------------------------
To run the CI/CD samples, you will need to first install some secrets via...

    ./createsecrets.sh -u <DockerUser> -p <DockerPwd> \
        -e <GitHubEmailAddr> \
        -gt <gitHubToken>

(Note - This script supports DockerHub by default, but can support other CR repos)

Then do...

    kubectl create -n argo -f WorkflowTemplates/ci-docker-template.yaml --dry-run=client
    kubectl create -n argo -f WorkflowTemplates/ci-docker-template.yaml

    kubectl create -f Workflows/ci-docker-build.yaml --dry-run=client
    argo submit -n argo Workflows/ci-docker-build.yaml --watch \
        -p IMAGE_NAME=<DockerUser>/<imageName>
    argo list -n argo
    argo logs -n argo @latest


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
- https://argoproj.github.io/argo-workflows/quick-start/
- https://argoproj.github.io/argo-workflows/argo-server-sso/
- https://github.com/argoproj/argo-workflows/blob/master/examples/README.md
- https://argoproj.github.io/argo-events/
- https://github.com/argoproj/argo-workflows/tree/master/examples
