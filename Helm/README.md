Helm Samples
============

This repo has a couple of example Helm deployment samples.

What is Helm?
-------------
Helm is a package manager and templating engine that sits on top of Kubernetes. It is one of a couple of options
that can be used in this type of area, but it is one of the most common ones.

This repo has some precanned Helm packages which can be used with the helper script to demonstrate the functionality
and how to use the commands. You can either use the helper script or debug the script to find out the actual Helm
commands used. The helper script is provided as a method of convinence for formatting commands and doing necessary
prep work.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed Helm (helm) and the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Running the samples
-------------------
To run the samples, please do the following steps.

    cd /tmp
    git clone https://github.com/tpayne/kubernetes-examples
    cd kubernetes-examples/Helm

The following commands will check the Helm package syntax and then install the package

    ./helm_samples.sh -n standard3tier-deployment -l -a \
        -iurl https://raw.githubusercontent.com/tpayne/kubernetes-examples/main/Helm/
    ./helm_samples.sh -n standard3tier-deployment -i

The following command will display information about the deployed package

    ./helm_samples.sh -n standard3tier-deployment -v

The following command will display information about the deployed package and then rollback the
deployment to a previous release

    ./helm_samples.sh -n standard3tier-deployment -r -v

The following command will uninstall the Helm package and then generate an error as no packages are
installed

    ./helm_samples.sh -n standard3tier-deployment -u -v
    ./helm_samples.sh -n standard3tier-deployment -v

The following command will pull a Helm package from the repo

    ./helm_samples.sh -n standard3tier-deployment --pull
    ls *.tgz

The following command will show the expanded syntax

    ./helm_samples.sh -n standard3tier-deployment -e

Helper Script
-------------
The helper script wraps the majority of the Helm commands and allows many commands to be sequenced together 
to achieve a CI/CD flow. The script has been developed to support specific command flows and git repo locations
as such, if you wish to use the script outside of this context, please review and modify it as appropriate.

The following command for example will run a sequence of Helm commands to...

    ./helm_samples.sh -n canary-deployment -l -p -a -i -v \
        -iurl https://raw.githubusercontent.com/tpayne/kubernetes-examples/main/Helm --force

- Lint a Helm chart and test it for syntax errors
- Create a new Helm index and package
- Update the git repo with the new package and changed Helm code
- Install a Helm repo definition (if needed)
- Uninstall the existing package - if installed
- Install the Helm chart/package in the K8s system
- Verify the install

(Note - You cannot run this command on this repo as you will be blocked from the git commit. The above
is only provided as a sample).

    ./helm_samples.sh -n wscs-b-deployment -u 

Notes
-----
- https://helm.sh/docs/topics/charts/
- The examples contained in this repo are focusing on core functionality only and show various use-cases
