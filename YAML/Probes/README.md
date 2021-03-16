Probe Sample
============

This repo contains an example which shows how to do liveliness and readiness probe using Kubernetes.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`. 

Running the Example
-------------------
This solution uses Kubernete's liveliness probe to show pod restarting when liveliness checks fail.

To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please run the following...

    % kubectl delete all -n logicapp-probe --all; \
        kubectl delete namespace logicapp-probe; \
        kubectl create -f probe-deployment.yaml
    % kubectl get all -n logicapp-probe

If everything has worked as expected, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-prode
    NAME                   READY   STATUS    RESTARTS   AGE
    pod/logicapp-pod-exe   1/1     Running   0          3s
    pod/logicapp-pod-tcp   1/1     Running   0          3s

To show the solution, use the pod id shown above run the following command...

    % kubectl logs logicapp-pod-exe -n logicapp-probe -f
    1
    Touch file...
    2
    Touch file...
    3
    Touch file...
    4
    Touch file...
    5
    Touch file...
    6
    Time to die...
    7
    Time to die...
    8
    Time to die...
    9
    Time to die...
    10
    Time to die...

When it dies, you will see that the pod has been restarted...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-probe
    NAME                   READY   STATUS    RESTARTS   AGE
    pod/logicapp-pod-exe   1/1     Running   1          3s
    pod/logicapp-pod-tcp   1/1     Running   0          3s

Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete all --all -n logicapp-probe; kubectl delete namespace logicapp-probe
        
This will delete all the items created in your Kubernetes installation.
