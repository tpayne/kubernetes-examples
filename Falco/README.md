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

First, install the Falco (with sidekick)...

    ./deployfalco.sh -s

If you want to install Falco with Kubeless (which is no longer supported), then do...

    ./deployfalco.sh -s -k

If you want to install a custom ruleset, you can use...

    ./deployfalco.sh -c -s

Deploying the Kubeless samples, you can do...

    (kubectl apply -n kubeless -f kubeless/ns.yml && \
        kubectl apply -n kubeless -f kubeless/roles.yml && \
        kubectl apply -n kubeless -f kubeless/function.yml)

Cleaning Up
-----------
To clean up the installation, do the following...

    ./deployfalco.sh -d

This will delete all the Falco items created in your Kubernetes installation, although it may have a while.

Notes
-----
As of 15th of Dec, 2021, Kubeless has been archived as a project which means it will no longer be actively maintained by its developers. As such, the tooling no longer works as it should for installations etc. I have worked around this issue to get it to install using my scripts, but what the behaviour of the product is at this point is up in the air so do not be surprised if it does odd things.

- https://falco.org/labs/
- https://falco.org/docs/rules/
- https://falco.org/docs/alerts/
- https://en.wikipedia.org/wiki/Security_information_and_event_management
- https://github.com/falcosecurity/charts/
- https://www.acloudjourney.io/blog/threat-detection-on-aks-with-falco#:~:text=%20Besides%20that%2C%20you%20may%20want%20to%20dig,may%20want%20to%20use%20this%20integration...%20More%20
- https://kubeless.io/docs/quick-start/
- https://github.com/vmware-archive/kubeless
