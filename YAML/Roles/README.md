Roles Sample
============

This repo contains an example which shows how to do roles using Kubernetes.

Roles are used to limit what users or groups can do in Kubernetes. Roles are
namespaced. ClusterRoles are non-namespaced

- https://kubernetes.io/docs/reference/access-authn-authz/rbac/

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl) 
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`. 

Running the Example
-------------------
This solution uses Kubernete's Role support to apply roles to users.

To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please run the following...

    % kubectl delete all --all -n logicapp-prod; \
        kubectl delete ns logicapp-prod; kubectl delete clusterrolebinding admin-nodes; \
        kubectl delete clusterrole nodeadmin; \
        kubectl create -f roles.yaml
    % kubectl get clusteroles
    % kubectl get role -n logicapp-prod

If everything has worked as expected, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get clusterroles
    NAME                                                                   CREATED AT
    admin                                                                  2021-03-15T22:17:18Z
    aks-service                                                            2021-03-15T22:17:50Z
    azure-policy-webhook-cluster-role                                      2021-03-15T22:17:53Z
    cluster-admin                                                          2021-03-15T22:17:18Z
    container-health-log-reader                                            2021-03-15T22:17:53Z
    edit                                                                   2021-03-15T22:17:18Z
    gatekeeper-manager-role                                                2021-03-15T22:17:53Z
    nodeadmin                                                              2021-04-02T13:45:09Z
    omsagent-reader                                                        2021-03-15T22:17:51Z
    policy-agent                                                           2021-03-15T22:17:53Z
    system:aggregate-to-admin                                              2021-03-15T22:17:18Z
    system:aggregate-to-edit                                               2021-03-15T22:17:18Z
    system:aggregate-to-view                                               2021-03-15T22:17:18Z
    system:auth-delegator                                                  2021-03-15T22:17:18Z
    system:azure-cloud-provider                                            2021-03-15T22:17:53Z
    system:azure-cloud-provider-secret-getter                              2021-03-15T22:17:53Z
    system:basic-user                                                      2021-03-15T22:17:18Z
    system:certificates.k8s.io:certificatesigningrequests:nodeclient       2021-03-15T22:17:18Z
    system:certificates.k8s.io:certificatesigningrequests:selfnodeclient   2021-03-15T22:17:18Z
    system:certificates.k8s.io:kube-apiserver-client-approver              2021-03-15T22:17:18Z
    system:certificates.k8s.io:kube-apiserver-client-kubelet-approver      2021-03-15T22:17:18Z
    system:certificates.k8s.io:kubelet-serving-approver                    2021-03-15T22:17:18Z
    system:certificates.k8s.io:legacy-unknown-approver                     2021-03-15T22:17:18Z
    system:controller:attachdetach-controller                              2021-03-15T22:17:19Z
    system:controller:certificate-controller                               2021-03-15T22:17:19Z
    system:controller:clusterrole-aggregation-controller                   2021-03-15T22:17:19Z
    system:controller:cronjob-controller                                   2021-03-15T22:17:19Z
    system:controller:daemon-set-controller                                2021-03-15T22:17:19Z
    system:controller:deployment-controller                                2021-03-15T22:17:19Z
    system:controller:disruption-controller                                2021-03-15T22:17:19Z
    system:controller:endpoint-controller                                  2021-03-15T22:17:19Z
    system:controller:endpointslice-controller                             2021-03-15T22:17:19Z
    system:controller:endpointslicemirroring-controller                    2021-03-15T22:17:19Z
    system:controller:expand-controller                                    2021-03-15T22:17:19Z
    system:controller:generic-garbage-collector                            2021-03-15T22:17:19Z
    system:controller:horizontal-pod-autoscaler                            2021-03-15T22:17:19Z
    system:controller:job-controller                                       2021-03-15T22:17:19Z
    system:controller:namespace-controller                                 2021-03-15T22:17:19Z
    system:controller:node-controller                                      2021-03-15T22:17:19Z
    system:controller:persistent-volume-binder                             2021-03-15T22:17:19Z
    system:controller:pod-garbage-collector                                2021-03-15T22:17:19Z
    system:controller:pv-protection-controller                             2021-03-15T22:17:19Z
    system:controller:pvc-protection-controller                            2021-03-15T22:17:19Z
    system:controller:replicaset-controller                                2021-03-15T22:17:19Z
    system:controller:replication-controller                               2021-03-15T22:17:19Z
    system:controller:resourcequota-controller                             2021-03-15T22:17:19Z
    system:controller:route-controller                                     2021-03-15T22:17:19Z
    system:controller:service-account-controller                           2021-03-15T22:17:19Z
    system:controller:service-controller                                   2021-03-15T22:17:19Z
    system:controller:statefulset-controller                               2021-03-15T22:17:19Z
    system:controller:ttl-controller                                       2021-03-15T22:17:19Z
    system:coredns                                                         2021-03-15T22:17:53Z
    system:coredns-autoscaler                                              2021-03-15T22:17:53Z
    system:discovery                                                       2021-03-15T22:17:18Z
    system:heapster                                                        2021-03-15T22:17:18Z
    system:kube-aggregator                                                 2021-03-15T22:17:18Z
    system:kube-controller-manager                                         2021-03-15T22:17:18Z
    system:kube-dns                                                        2021-03-15T22:17:18Z
    system:kube-scheduler                                                  2021-03-15T22:17:18Z
    system:kubelet-api-admin                                               2021-03-15T22:17:18Z
    system:metrics-server                                                  2021-03-15T22:17:50Z
    system:node                                                            2021-03-15T22:17:18Z
    system:node-bootstrapper                                               2021-03-15T22:17:18Z
    system:node-problem-detector                                           2021-03-15T22:17:18Z
    system:node-proxier                                                    2021-03-15T22:17:18Z
    system:persistent-volume-provisioner                                   2021-03-15T22:17:18Z
    system:persistent-volume-secret-operator                               2021-03-15T22:17:51Z
    system:prometheus                                                      2021-03-15T22:17:45Z
    system:public-info-viewer                                              2021-03-15T22:17:18Z
    system:volume-scheduler                                                2021-03-15T22:17:18Z
    view                                                                   2021-03-15T22:17:18Z

    mac:LoadBalancer bob$ kubectl get role -n logicapp-prod
    NAME          CREATED AT
    pod-creator   2021-04-02T13:45:09Z
    pod-reader    2021-04-02T13:45:09Z

    mac:LoadBalancer bob$ kubectl get rolebinding -n logicapp-prod
    NAME         ROLE              AGE
    admin-pods   Role/pod-reader   4m8s
    read-pods    Role/pod-reader   4m8s

    mac:LoadBalancer bob$ kubectl describe rolebinding admin-pods -n logicapp-prod
    Name:         admin-pods
    Labels:       <none>
    Annotations:  <none>
    Role:
      Kind:  Role
      Name:  pod-reader
    Subjects:
      Kind   Name   Namespace
      ----   ----   ---------
      User   james  
      Group  admin  

Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete all --all -n logicapp-prod; \
        kubectl delete ns logicapp-prod; kubectl delete clusterrolebinding admin-nodes; \
        kubectl delete clusterrole nodeadmin;
        
This will delete all the items created in your Kubernetes installation.

