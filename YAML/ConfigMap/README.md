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
    % kubectl describe configmap -n logicapp-prod
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
    system
    /secrets:
    total 4
    drwxrwxrwt    3 root     root           100 Mar 14 19:36 .
    drwxr-xr-x    1 root     root          4096 Mar 14 19:36 ..
    drwxr-xr-x    3 root     root            60 Mar 14 19:36 ..2021_03_14_19_36_03.331067580
    lrwxrwxrwx    1 root     root            31 Mar 14 19:36 ..data -> ..2021_03_14_19_36_03.331067580
    lrwxrwxrwx    1 root     root            13 Mar 14 19:36 dbdata -> ..data/dbdata

    /secrets/..2021_03_14_19_36_03.331067580:
    total 0
    drwxr-xr-x    3 root     root            60 Mar 14 19:36 .
    drwxrwxrwt    3 root     root           100 Mar 14 19:36 ..
    drwxr-xr-x    2 root     root            60 Mar 14 19:36 dbdata

    /secrets/..2021_03_14_19_36_03.331067580/dbdata:
    total 4
    drwxr-xr-x    2 root     root            60 Mar 14 19:36 .
    drwxr-xr-x    3 root     root            60 Mar 14 19:36 ..
    -rw-r--r--    1 root     root             6 Mar 14 19:36 condb
    system/config_data:
    total 12
    drwxrwxrwx    3 root     root          4096 Mar 14 19:36 .
    drwxr-xr-x    1 root     root          4096 Mar 14 19:36 ..
    drwxr-xr-x    2 root     root          4096 Mar 14 19:36 ..2021_03_14_19_36_02.658687121
    lrwxrwxrwx    1 root     root            31 Mar 14 19:36 ..data -> ..2021_03_14_19_36_02.658687121
    lrwxrwxrwx    1 root     root            25 Mar 14 19:36 appDemo.properties -> ..data/appDemo.properties
    lrwxrwxrwx    1 root     root            20 Mar 14 19:36 db.properties -> ..data/db.properties

    /config_data/..2021_03_14_19_36_02.658687121:
    total 16
    drwxr-xr-x    2 root     root          4096 Mar 14 19:36 .
    drwxrwxrwx    3 root     root          4096 Mar 14 19:36 ..
    -rw-r--r--    1 root     root            56 Mar 14 19:36 appDemo.properties
    -rw-r--r--    1 root     root            69 Mar 14 19:36 db.properties
    appkey.key1=value1
    appkey.key2=value2
    dbkey.key1=value1

Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete all --all -n logicapp-prod; kubectl delete namespace logicapp-prod

This will delete all the items created in your Kubernetes installation.
