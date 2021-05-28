Postgres Sample
===============

This repo contains an example front/backend deployment in Kubernetes.

StatefulSets are used to maintain machine names and IP used between pod restarts.

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

To show the solution, use the EXTERNAL_IP shown above run the following command (use password as the password)...

    kubectl exec postgres-client -it -n db-frontend -- psql -h <DatabaseServerIP> -U postgres -c "select * from pg_database"

Cleaning Up
-----------
To clean up the installation, do the following...

    ./reset.sh -d

This will delete all the items created in your Kubernetes installation.

Notes
-----
- https://hub.docker.com/_/postgres
- This example is only for demo purposes. IT WILL NOT WORK IN PRODUCTION ENVIRONMENTS DUE TO POSSIBLE DATA INSCONSISTENCY ISSUES
