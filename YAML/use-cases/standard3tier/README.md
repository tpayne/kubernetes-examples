Standard 3 Tier Sample
======================

This repo contains an example front/backend/monitor deployment in Kubernetes.

StatefulSets are used to maintain database machine names and IP used between pod restarts.

The PG server and PG client are in a separate namespace and neither are exposed to the internet.

The frontend app is in its own namespace is hidden behind a load balancer which is exposed to the internet.
The frontend apps themselves are not.

The monitors are deployed to their own namespace and monitor all production environments.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl) and Postgres client (psql)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`.

Running the Example
-------------------
This solution uses Kubernete's StatefulSets to maintain a PSQL installation.

To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    kubectl config get-contexts
    kubectl config use-context <default>
    kubectl config current-context

Once you have setup the client to point to the desired Kubernetes server, please run the following...

    ./reset.sh

This script will deploy the resources for you and then display the database server IP to use below.

Accessing the PG Server
-----------------------
To access the DB server, use the database server IP shown above run the following command (use password as the password)...

    kubectl exec postgres-client -it -n db-frontend -- psql -h <DatabaseServerIP> -U postgres -c "select * from pg_database"

This will use the postgres client installed on Kubernetes to run the PSQL. Nothing is exposed to the public internet.

Accessing the Frontend App
--------------------------
To access the frontend app, you can use...

    curl <IngressLB>/user/version

This will return some pseudo HTML with a version number

Accessing the Monitor
---------------------
To access the monitors, you can use...

    kubectl get all -n monitor
    kubectl logs daemonset.apps/node-monitor -n monitor -f -c node-monitor
    kubectl logs daemonset.apps/node-monitor -n monitor -f -c fluentd-esearch

Cleaning Up
-----------
To clean up the installation, do the following...

    ./reset.sh -d

This will delete all the items created in your Kubernetes installation.

Notes
-----
- https://hub.docker.com/_/postgres
- https://github.com/fluent/fluentd-kubernetes-daemonset
- https://medium.com/kubernetes-tutorials/cluster-level-logging-in-kubernetes-with-fluentd-e59aa2b6093a
- https://docs.fluentd.org
- This example is only for demo purposes
