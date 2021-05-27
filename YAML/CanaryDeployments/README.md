Canary Deployment Sample
=========================

This repo contains an example which shows how to do a Canary deployment using Kubernetes.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`. 

Running the Example
-------------------
This solution uses Kubernete's default LoadBalancing endpoint support to provide load balancing
between two different versions of an application.

To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    kubectl config get-contexts
    kubectl config use-context <default>
    kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please run the following...

    kubectl delete all -n logicapp-prod --all; \
        kubectl delete namespace logicapp-prod; \
        kubectl create -f canary-deployment.yaml
    kubectl get all -n logicapp-prod

If everything has worked as expected, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-prod
    NAME                                     READY   STATUS    RESTARTS   AGE
    pod/logicapp-canary-599b57db5f-mqnwj     1/1     Running   0          8m33s
    pod/logicapp-deployment-cdf4b945-ckqxd   1/1     Running   0          8m33s
    pod/logicapp-deployment-cdf4b945-nmcxv   1/1     Running   0          8m33s
    pod/logicapp-deployment-cdf4b945-r75ld   1/1     Running   0          8m33s

    NAME                            TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
    service/logicapp-prod-service   LoadBalancer   10.0.115.132   <external-ip>   80:30513/TCP   8m34s

    NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/logicapp-canary       1/1     1            1           8m34s
    deployment.apps/logicapp-deployment   3/3     3            3           8m34s

    NAME                                           DESIRED   CURRENT   READY   AGE
    replicaset.apps/logicapp-canary-599b57db5f     1         1         1       8m34s
    replicaset.apps/logicapp-deployment-cdf4b945   3         3         3       8m34s

To show the solution, use the EXTERNAL-IP shown above run the following CURL...

    curl 20.49.158.192/user/version
    <h2>Version 1.0</h2>
    curl 20.49.158.192/user/version
    {"timestamp":"2021-03-13T23:25:26.540+0000","status":404,"error":"Not Found","message":"No message available","path":"/user/version"}

If you get `<h2>Version 1.0</h2>`, you are hitting the canary deployment (1 pod).

If you get `{"timestamp":"2021-03-13T23:25:26.540+0000","status":404,"error":...}`, you are hitting the stable version.

Cleaning Up
-----------
To clean up the installation, do the following...

    kubectl delete all --all -n logicapp-prod && kubectl delete namespace logicapp-prod
        
This will delete all the items created in your Kubernetes installation.
