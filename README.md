Kubernetes Examples Repo
========================

This repo contains various examples of Kubernetes projects that have been created to help people get started with (Maven and) Kubernetes.

It is assumed you have a basic understanding of what Kubernetes and Docker is. If not, then please see the notes below.

Status
------
````
Kubernetes Example Status: Ready for use
````
Build CI/Testing Status
-----------------------
The following indicates the CI and coverage status.

[![Build Status](https://travis-ci.org/tpayne/kubernetes-examples.svg?branch=main)](https://travis-ci.org/tpayne/kubernetes-examples)
[![Java CI with Maven](https://github.com/tpayne/kubernetes-examples/actions/workflows/maven.yml/badge.svg?branch=main)](https://github.com/tpayne/kubernetes-examples/actions/workflows/maven.yml)

Kubernetes Examples
-------------------
The examples contained in this repo run on Maven and Kubernetes. They are based in the following directories.

>| Project | Description | 
>| ------- | ----------- |
>| [Maven/web8k-example/](https://github.com/tpayne/kubernetes-examples/tree/main/Maven/web8k-example) | This sample will use Maven and various plugins to build, push a deploy a custom spring app to a specified Kubernetes repo |
>| [YAML/CanaryDeployments/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/CanaryDeployments) | This sample will use YAML to create a canary deployment solution to a specified Kubernetes repo |
>| [YAML/ConfigMap/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/ConfigMap) | This sample will use YAML to create various config maps/secrets to a specified Kubernetes repo |
>| [YAML/CronJobs/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/CronJobs) | This sample will use YAML to show how to use CronJobs |
>| [YAML/DaemonSets/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/DaemonSets) | This sample will use YAML to show how to use DaemonSets and monitoring solutions |
>| [YAML/LoadBalancer/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/LoadBalancer) | This sample will use YAML to create various load balancing/redirection solutions to a specified Kubernetes repo |
>| [YAML/Probes/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/Probes) | This sample will use YAML to show how to use probes |
>| [YAML/RollingUpdate/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/RollingUpdate) | This sample will use YAML to show rolling update strategies in a specified Kubernetes repo |
>| [YAML/Roles/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/Roles) | This sample will use YAML to show how to use roles |
>| [YAML/ServiceMesh/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/ServiceMesh) | This sample will use YAML to show how to use Service Meshes |
>| [YAML/StatefulSets/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/StatefulSets) | This sample will use YAML to show how to use StatefulSets |
>| [YAML/use-cases/postgres](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/use-cases/postgres) | This sample will use YAML to show how to host front/backend DB services |
>| [gitops/azurearc/](https://github.com/tpayne/kubernetes-examples/tree/main/gitops/azurearc) | This sample will use Helm and Arc to setup GitOps in Azure |
>| [gitops/gcp/](https://github.com/tpayne/kubernetes-examples/tree/main/gitops/gcp) | This sample will use Cloud Build and Kubectl to setup GitOps in GCP |

Clean Up
--------
After you have finished you can clean up your Docker repo with the following commands...

    docker system df
    docker system prune --all -f
    
Be sure you want to run this command however as it will reclaim all unused space!

Notes on Configs
----------------
You can merge Kubeconfigs with the following...
    
    export KUBECONFIG=~/.kube/config:~/new-config-file 
    kubectl config view --flatten

Notes on Network Control
------------------------
Network control (ingress/egress) Calico policies are managed by Network Policies
- https://kubernetes.io/docs/concepts/services-networking/network-policies/

Notes for Getting Started
-------------------------
- https://kubernetes.io/docs
- https://docs.docker.com

Liability Warning
-----------------
The contents of this repository (documents and examples) are provided “as-is” with no warrantee implied 
or otherwise about the accuracy or functionality of the examples.

You use them at your own risk. If anything results to your machine or environment or anything else as a 
result of ignoring this warning, then the fault is yours only and has nothing to do with me.
