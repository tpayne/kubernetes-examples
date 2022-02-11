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

Introduction to Kubernetes
--------------------------
The following is a training video I put together for Kubernetes and Microservices...

[![Intro into K8s](https://img.youtube.com/vi/VT_8cJ3Lxog/0.jpg)](https://www.youtube.com/watch?v=VT_8cJ3Lxog)

Kubernetes Examples
-------------------
The examples contained in this repo run on Maven and Kubernetes. They are based in the following directories.

>| Project | Description |
>| ------- | ----------- |
>| [Maven/web8k-example/](https://github.com/tpayne/kubernetes-examples/tree/main/Maven/web8k-example) | This sample will use Maven and various plugins to build, push a deploy a custom spring app to a specified Kubernetes repo |
>| [Falco/](https://github.com/tpayne/kubernetes-examples/tree/main/Falco) | These samples use Helm to install Falco security tools into Kubernetes |
>| [Helm/](https://github.com/tpayne/kubernetes-examples/tree/main/Helm) | These samples use Helm to install packages into Kubernetes |
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
>| [YAML/AGIC/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/Azure/AGIC/Redirection) | This sample shows you how to use the Azure AGW Ingress Controllers with AKS|

These samples will run on any Kubernetes provider.

Kubernetes Use-cases
--------------------
The following examples show some common deployment types using Kubernetes.

>| Project | Description |
>| ------- | ----------- |
>| [YAML/use-cases/postgres](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/use-cases/postgres) | This sample will use YAML to show how to setup front/backend DB services |
>| [YAML/use-cases/standard3tier](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/use-cases/standard3tier) | This sample will use YAML to show how to setup DB services, frontend apps and a monitoring service |

These samples will run on any Kubernetes provider.

Kubernetes GitOps
-----------------
The following examples show example methods for implementing `GitOps` using Kubernetes.

>| Project | Description |
>| ------- | ----------- |
>| [gitops/azurearc/](https://github.com/tpayne/kubernetes-examples/tree/main/gitops/azurearc) | This sample will use Helm and Arc to setup GitOps in Azure |
>| [gitops/gcp/](https://github.com/tpayne/kubernetes-examples/tree/main/gitops/gcp) | This sample will use Cloud Build and Kubectl to setup GitOps in GCP |

These samples will only run on GCP and Azure appropriately.

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

You can also use krew/konfig

Notes on Network Control
------------------------
Network control (ingress/egress) Calico policies are managed by Network Policies
- https://kubernetes.io/docs/concepts/services-networking/network-policies/

Notes for Getting Started
-------------------------
- https://kubernetes.io/docs
- https://docs.docker.com
- https://github.com/kubernetes-sigs/kustomize
- https://medium.com/stakater/k8s-deployments-vs-statefulsets-vs-daemonsets-60582f0c62d4
- https://krew.sigs.k8s.io/
- https://github.com/corneliusweig/konfig
- https://kubernetes-tutorial.schoolofdevops.com/advanced_pod_scheduling/
- https://github.com/kubernetes/dns/blob/master/docs/specification.md
- https://learnk8s.io/validating-kubernetes-yaml
- https://kubevious.io/blog/post/top-kubernetes-yaml-validation-tools
- https://www.educba.com/kubernetes-yaml-validator/

Notes
-----
- Set default namespace via `kubectl config set-context <context> --namespace=<defaultNs>`
- Various management commands to be aware of...
    - cordon = Mark a node as unscheduleable, i.e. not able to do any new deployments to it
    - uncordon = Mark a node as scheduleable
    - drain = Drain node of all unused transactions (safely)
    - taint = Reserve nodes for scheduling of deployments with tolerances set

Liability Warning
-----------------
The contents of this repository (documents and examples) are provided “as-is” with no warrantee implied
or otherwise about the accuracy or functionality of the examples.

You use them at your own risk. If anything results to your machine or environment or anything else as a
result of ignoring this warning, then the fault is yours only and has nothing to do with me.
