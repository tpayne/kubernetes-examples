Maven Spring Kubernetes Sample
==============================

This is a Maven project for building and deploying a small custom spring application...

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- Installed Maven (mvn)
- Logged into a terminal window that will allow you to do deployments to a valid K8 cluster
- Have your Kubernetes context set to a system you have permission to deploy to

Build Instructions
------------------
To run this sample do the following...

    mvn clean package 
    mvn k8s:build k8s:resource k8s:deploy
    docker images
    kubectl get deployments
    kubectl get services
