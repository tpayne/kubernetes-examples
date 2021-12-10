Falco Samples
=============

This repo has a couple of example Kubernetes deployment YAML files that show how to use the
Falco SOAR and SIEM security system.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed Helm (helm) and the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to
- You have access to an Azure account as an admin (or have permission to create clusters and deployments)

Running the samples
-------------------
To run the samples, please do the following steps.

First, install the Falco...

    ./deployfalco.sh

Cleaning Up
-----------
To clean up the installation, do the following...

    ./deployfalco.sh -d

This will delete all the Falco items created in your Kubernetes installation.

Notes
-----
- https://falco.org/labs/
- https://falco.org/docs/rules/
- https://falco.org/docs/alerts/
- https://github.com/falcosecurity/charts/
- https://www.acloudjourney.io/blog/threat-detection-on-aks-with-falco#:~:text=%20Besides%20that%2C%20you%20may%20want%20to%20dig,may%20want%20to%20use%20this%20integration...%20More%20
