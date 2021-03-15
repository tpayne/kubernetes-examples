Rolling Update Sample
=====================

This repo contains an example which shows how to do a rolling update using Kubernetes.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`. 

Running the Example
-------------------
This solution uses Kubernete's default rolling update strategy support to show how to updates
and rollbacks.

To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please run the following...

    % kubectl delete all -n logicapp-prod --all; \
        kubectl delete namespace logicapp-prod; \
        kubectl create -f update-deployment.yaml --record
    % kubectl get all -n logicapp-prod

The `--record` option will record the history of changes to the deployment.

This command will dump the deployment as YAML, so you can look at it...

    % kubectl get deploy logicapp-deployment -o yaml -n logicapp-pro

If everything has worked as expected, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-prod
    NAME                                     READY   STATUS    RESTARTS   AGE
    pod/logicapp-deployment-cdf4b945-42kk6   1/1     Running   0          12s
    pod/logicapp-deployment-cdf4b945-42lbv   1/1     Running   0          12s
    pod/logicapp-deployment-cdf4b945-6f7bh   1/1     Running   0          12s
    pod/logicapp-deployment-cdf4b945-rjkwr   1/1     Running   0          12s

    NAME                            TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
    service/logicapp-prod-service   LoadBalancer   10.0.25.165   20.49.243.228   80:31064/TCP   13s

    NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/logicapp-deployment   4/4     4            4           13s

    NAME                                           DESIRED   CURRENT   READY   AGE
    replicaset.apps/logicapp-deployment-cdf4b945   4         4         4       13s

You then need to  the following command...

    % kubectl rollout history deployment logicapp-deployment -n logicapp-prod
    REVISION  CHANGE-CAUSE
    1         kubectl create --filename=update-deployment.yaml --record=true
    % kubectl set image deployment logicapp-deployment samplev1=tpayne666/samples:latest --record -n logicapp-prod

Optionally, if you want to look at the YAML to confirm the change, do...

    % kubectl edit deployment logicapp-deployment -n logicapp-prod

Then, run the following to monitor the update..

    % kubectl rollout status deployment logicapp-deployment -n logicapp-prod
    % kubectl rollout history deployment logicapp-deployment -n logicapp-prod
    deployment.apps/logicapp-deployment 
    REVISION  CHANGE-CAUSE
    1         kubectl create --filename=update-deployment.yaml --record=true
    2         kubectl set image deployment logicapp-deployment samplev1=tpayne666/samples:latest --record=true --namespace=logicapp-prod

    % kubectl describe deployment logicapp-deployment -n logicapp-prod 
    Name:                   logicapp-deployment
    Namespace:              logicapp-prod
    CreationTimestamp:      Mon, 15 Mar 2021 17:55:16 +0000
    Labels:                 <none>
    Annotations:            deployment.kubernetes.io/revision: 4
                            kubernetes.io/change-cause:
                              kubectl set image deployment logicapp-deployment samplev1=tpayne666/samples:latest --record=true --namespace=logicapp-prod
    Selector:               app=logicapp-deployment
    Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
    StrategyType:           RollingUpdate
    MinReadySeconds:        0
    RollingUpdateStrategy:  1 max unavailable, 1 max surge
    Pod Template:
      Labels:  app=logicapp-deployment
               env=prod
      Containers:
       samplev1:
        Image:        tpayne666/samples:latest
        Port:         8080/TCP
        Host Port:    0/TCP
        Environment:  <none>
        Mounts:       <none>
      Volumes:        <none>
    Conditions:
      Type           Status  Reason
      ----           ------  ------
      Available      True    MinimumReplicasAvailable
      Progressing    True    NewReplicaSetAvailable
    OldReplicaSets:  <none>
    NewReplicaSet:   logicapp-deployment-85c98cc8d9 (4/4 replicas created)
    Events:
      Type    Reason             Age                  From                   Message
      ----    ------             ----                 ----                   -------
      Normal  ScalingReplicaSet  14m                  deployment-controller  Scaled up replica set logicapp-deployment-cdf4b945 to 4
      Normal  ScalingReplicaSet  11m                  deployment-controller  Scaled up replica set logicapp-deployment-85c98cc8d9 to 1
      Normal  ScalingReplicaSet  11m                  deployment-controller  Scaled up replica set logicapp-deployment-85c98cc8d9 to 2
      Normal  ScalingReplicaSet  11m                  deployment-controller  Scaled down replica set logicapp-deployment-cdf4b945 to 2
      Normal  ScalingReplicaSet  11m                  deployment-controller  Scaled up replica set logicapp-deployment-85c98cc8d9 to 3
      Normal  ScalingReplicaSet  11m                  deployment-controller  Scaled up replica set logicapp-deployment-85c98cc8d9 to 4
      Normal  ScalingReplicaSet  11m                  deployment-controller  Scaled down replica set logicapp-deployment-cdf4b945 to 0
      Normal  ScalingReplicaSet  26s (x2 over 11m)    deployment-controller  Scaled down replica set logicapp-deployment-cdf4b945 to 3
      Normal  ScalingReplicaSet  23s (x2 over 11m)    deployment-controller  Scaled down replica set logicapp-deployment-cdf4b945 to 1
      Normal  ScalingReplicaSet  19s (x14 over 4m5s)  deployment-controller  (combined from similar events): Scaled down replica set logicapp-deployment-cdf4b945 to 0

The update will now be rolled out. To rollback to the last version (the initial one), you can do...

    % kubectl rollout undo deployment logicapp-deployment --to-revision=1 -n logicapp-prod
    % kubectl rollout history deployment logicapp-deployment -n logicapp-prod
    deployment.apps/logicapp-deployment 
    REVISION  CHANGE-CAUSE
    2         kubectl set image deployment logicapp-deployment samplev1=tpayne666/samples:latest --record=true --namespace=logicapp-prod
    3         kubectl create --filename=update-deployment.yaml --record=true

To check it has the original version...

    % kubectl describe deployment logicapp-deployment -n logicapp-prod 
    Name:                   logicapp-deployment
    Namespace:              logicapp-prod
    CreationTimestamp:      Mon, 15 Mar 2021 17:55:16 +0000
    Labels:                 <none>
    Annotations:            deployment.kubernetes.io/revision: 3
                            kubernetes.io/change-cause: kubectl create --filename=update-deployment.yaml --record=true
    Selector:               app=logicapp-deployment
    Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
    StrategyType:           RollingUpdate
    MinReadySeconds:        0
    RollingUpdateStrategy:  1 max unavailable, 1 max surge
    Pod Template:
      Labels:  app=logicapp-deployment
               env=prod
      Containers:
       samplev1:
        Image:        tpayne666/samples:v1.0
        Port:         8080/TCP
        Host Port:    0/TCP
        Environment:  <none>
        Mounts:       <none>
      Volumes:        <none>
    Conditions:
      Type           Status  Reason
      ----           ------  ------
      Available      True    MinimumReplicasAvailable
      Progressing    True    NewReplicaSetAvailable
    OldReplicaSets:  <none>
    NewReplicaSet:   logicapp-deployment-cdf4b945 (4/4 replicas created)
    Events:
      Type    Reason             Age                    From                   Message
      ----    ------             ----                   ----                   -------
      Normal  ScalingReplicaSet  13m                    deployment-controller  Scaled up replica set logicapp-deployment-cdf4b945 to 4
      Normal  ScalingReplicaSet  9m25s                  deployment-controller  Scaled up replica set logicapp-deployment-85c98cc8d9 to 1
      Normal  ScalingReplicaSet  9m25s                  deployment-controller  Scaled down replica set logicapp-deployment-cdf4b945 to 3
      Normal  ScalingReplicaSet  9m25s                  deployment-controller  Scaled up replica set logicapp-deployment-85c98cc8d9 to 2
      Normal  ScalingReplicaSet  9m22s                  deployment-controller  Scaled down replica set logicapp-deployment-cdf4b945 to 2
      Normal  ScalingReplicaSet  9m22s                  deployment-controller  Scaled up replica set logicapp-deployment-85c98cc8d9 to 3
      Normal  ScalingReplicaSet  9m22s                  deployment-controller  Scaled down replica set logicapp-deployment-cdf4b945 to 1
      Normal  ScalingReplicaSet  9m22s                  deployment-controller  Scaled up replica set logicapp-deployment-85c98cc8d9 to 4
      Normal  ScalingReplicaSet  9m19s                  deployment-controller  Scaled down replica set logicapp-deployment-cdf4b945 to 0
      Normal  ScalingReplicaSet  2m12s (x8 over 2m17s)  deployment-controller  (combined from similar events): Scaled down replica set logicapp-deployment-85c98cc8d9 to 0


Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete all --all -n logicapp-prod; kubectl delete namespace logicapp-prod
        
This will delete all the items created in your Kubernetes installation.
