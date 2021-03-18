Kubernetes Examples Repo
========================

This repo contains various examples of Kubernetes projects that have been created to help people get started with (Maven and) Kubernetes.

Status
------
````
Kubernetes Example Status: Ready for use
````
Build CI/Testing Status
-----------------------
The following indicates the CI and coverage status.

[![Build Status](https://travis-ci.org/tpayne/kubernetes-examples.svg?branch=main)](https://travis-ci.org/tpayne/kubernetes-examples)

Kubernetes Examples
-------------------
The examples contained in this repo run on Maven and Kubernetes. They are based in the following directories.

>| Project | Description | 
>| ------- | ----------- |
>| [Maven/web8k-example/](https://github.com/tpayne/kubernetes-examples/tree/main/Maven/web8k-example) | This sample will use Maven and various plugins to build, push a deploy a custom spring app to a specified Kubernetes repo |
>| [YAML/LoadBalancer/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/LoadBalancer) | This sample will use YAML to create various load balancing/redirection solutions to a specified Kubernetes repo |
>| [YAML/CanaryDeployments/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/CanaryDeployments) | This sample will use YAML to create a canary deployment solution to a specified Kubernetes repo |
>| [YAML/ConfigMap/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/ConfigMap) | This sample will use YAML to create various config maps/secrets to a specified Kubernetes repo |
>| [YAML/RollingUpdate/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/RollingUpdate) | This sample will use YAML to show rolling update strategies in a specified Kubernetes repo |
>| [YAML/Probes/](https://github.com/tpayne/kubernetes-examples/tree/main/YAML/Probes) | This sample will use YAML to show how to use probes |

Clean Up
--------
After you have finished you can clean up your Docker repo with the following commands...

    docker system df
    docker system prune --all -f
    
Be sure you want to run this command however as it will reclaim all unused space!

Notes
-----
You can merge Kubeconfigs with the following...
    
    export KUBECONFIG=~/.kube/config:~/new-config-file 
    kubectl config view --flatten
