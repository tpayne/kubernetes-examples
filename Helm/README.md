Helm Samples
============

This repo has a couple of example Helm deployment samples.

This repo is still WIP - do not use

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed Helm (helm) and the Kubernetes client (kubectl)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Running the samples
-------------------
To run the samples, please do the following steps.

    git clone https://github.com/tpayne/kubernetes-examples
    cd kubernetes-examples/Helm

The following command will check the Helm package syntax and then install the package

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

Notes
-----
TBD