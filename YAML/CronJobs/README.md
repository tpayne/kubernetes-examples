CronJobs Sample
===============

This repo contains an example which shows how to do CronJobs using Kubernetes.

CronJobs are used to run scheduled jobs in individual pods.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl) 
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`. 

Running the Example
-------------------
This solution uses Kubernete's Cronjob to run jobs once every 5 mins.

To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please run the following...

    % kubectl delete all --all -n logicapp-prod; \
        kubectl delete ns logicapp-prod; \
        kubectl create -f cronjon.yaml
    % kubectl get all -n logicapp-prod

If everything has worked as expected, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-prod
    NAME                           SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
    cronjob.batch/cronjob-sample   */5 * * * *   False     0        <none>          6s

To show the solution, wait 5-10 minutes then run the following command...

    % kubectl get all -n logicapp-prod
    NAME                                  READY   STATUS      RESTARTS   AGE
    pod/cronjob-sample-1616247000-5kgvz   0/1     Completed   0          4m37s

    NAME                                  COMPLETIONS   DURATION   AGE
    job.batch/cronjob-sample-1616247000   1/1           1s         4m39s

    NAME                           SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
    cronjob.batch/cronjob-sample   */5 * * * *   False     0        4m46s           5m30s

To view the results of the jobs, you can view the logs of the pod by...

    % kubectl logs pod/cronjob-sample-1616247000-5kgvz -n logicapp-prod
    AppRun:
    Sat Mar 20 13:30:08 UTC 2021
    KUBERNETES_PORT=tcp://10.0.0.1:443
    KUBERNETES_SERVICE_PORT=443
    HOSTNAME=cronjob-sample-1616247000-5kgvz
    SHLVL=1
    HOME=/root
    KUBERNETES_PORT_443_TCP_ADDR=10.0.0.1
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    KUBERNETES_PORT_443_TCP_PORT=443
    KUBERNETES_PORT_443_TCP_PROTO=tcp
    KUBERNETES_SERVICE_PORT_HTTPS=443
    KUBERNETES_PORT_443_TCP=tcp://10.0.0.1:443
    KUBERNETES_SERVICE_HOST=10.0.0.1
    PWD=/


Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete all --all -n logicapp-prod; kubectl delete namespace logicapp-prod;
        
This will delete all the items created in your Kubernetes installation.

