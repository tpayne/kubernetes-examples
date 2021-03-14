ConfigMap Sample
================

This repo contains an example which shows how to do a ConfigMap using Kubernetes.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`. 

Running the Example
-------------------
This solution uses Kubernete's default ConfigMapping support to show how to store properties.

To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please run the following...

    % kubectl delete all -n logicapp-prod --all; \
        kubectl delete namespace logicapp-prod; \
        kubectl create -f config-map.yaml
    % kubectl get all -n logicapp-prod

If everything has worked as expected, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-prod
    NAME                                  READY   STATUS    RESTARTS   AGE
    pod/configdemo-app-6ddbdddd49-jj4sh   1/1     Running   0          9s

    NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/configdemo-app   1/1     1            1           9s

    NAME                                        DESIRED   CURRENT   READY   AGE
    replicaset.apps/configdemo-app-6ddbdddd49   1         1         1       9s

To show the solution, use the pod id shown above run the following command...

    % kubectl logs <podId> -n logicapp-pro
    value1
    appDemo.properties
    db.properties
    appkey.key1=value1
    appkey.key2=value2
    dbkey.key1=value1
    value1
    appDemo.properties
    db.properties
    appkey.key1=value1
    appkey.key2=value2
    dbkey.key1=value1

Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete all --all -n logicapp-prod; kubectl delete namespace logicapp-prod
        
This will delete all the items created in your Kubernetes installation.
