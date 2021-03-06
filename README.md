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

Clean Up
--------
After you have finished you can clean up your Docker repo with the following commands...

    docker system df
    docker system prune --all -f
    
Be sure you want to run this command however as it will reclaim all unused space!
