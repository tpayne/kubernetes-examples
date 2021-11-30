AGIC Samples
============

This repo has a couple of example Kubernetes deployment YAML files that show how to use the
new Azure Application Gateway Ingress Controller.

At the time of writing these samples, the AGIC was a bit flaky, so the samples are not overly
complicated and use override annotations that in other circumstances you might not want to use.

(Note: These solutions are primarily intended for Kubernetes server `1.22+ only`. They have not been
vetted on earlier versions and use later network APIs which might not be available on previous versions).

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed Helm (helm) and the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to
- You have access to an Azure account as an admin (or have permission to create clusters and deployments)

Running the samples
-------------------
To run the samples, please do the following steps.

First, install the cluster and the controller...

    ./deploycontroller.sh

Once you have deployed the controller, you can install some basic examples...

    ./deployingress.sh
    ./deploycontroller.sh --getIp

These examples will show how the IC functionality works. You can try them by doing...

    curl <gatewayIp>/apicmd/version
    curl "<gatewayIp>/apiuser/hello?name=myName&surName=mySurname"

Installing Jenkins using the AGIC
---------------------------------
If you wish to get more adventurous and use Helm, you can try out the Jenkins example by doing the following...

    helm repo add jenkins https://charts.jenkins.io
    helm repo update
    kubectl create ns logicapp-jenkins
    helm install jenkins jenkins/jenkins -f jenkins-values.yaml
    kubectl get all -n logicapp-jenkins

You will need to wait a bit for everything to deploy and make itself stable (about 5 mins should be enough).

You can then open Jenkins using the IP obtained from...

    ./deploycontroller.sh --getIp
    open http://<gatewayIp>/jenkins

You can optain the password with...

    kubectl exec --namespace logicapp-jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo

Cleaning Up
-----------
To clean up the installation, do the following...

    ./deploycontroller.sh -d

This will delete all the items created in your Kubernetes installation.

Notes
-----
- These scripts are only for demo purposes and have not been thoroughly vetted for production use
- https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/application-gateway/redirect-internal-site-cli.md#:~:text=You%20can%20use%20az%20network%20public-ip%20show%20to,may%20change%20when%20the%20application%20gateway%20is%20restarted.
- https://github.com/jenkinsci/helm-charts
- https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/docs/tutorials/tutorial.e2e-ssl.md
- https://azure.github.io/application-gateway-kubernetes-ingress/annotations/#backend-path-prefix
- https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-annotations
- https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-private-ip
- https://github.com/Azure-Samples/app-gateway-ingress-controller
