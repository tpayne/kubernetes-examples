Postgres Sample
===============

This repo contains an example front/backend deployment in Kubernetes.

StatefulSets are used to maintain machine names and IP used between pod restarts.

The PG server and PG client are in separate namespaces and neither are exposed to the internet.

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

This script will deploy the resources for you and then display the database server IP to use in the connect statement below.

To show the solution, use the database server IP shown above run the following command (use password as the password)...

    kubectl exec postgres-client -it -n db-frontend -- psql -h <DatabaseServerIP> -U postgres -c "select * from pg_database"

This will use the postgres client installed on Kubernetes to run the PSQL against the database backend. 

Nothing is exposed to the public internet.

Cleaning Up
-----------
To clean up the installation, do the following...

    ./reset.sh -d

This will delete all the items created in your Kubernetes installation.

Notes
-----
- https://hub.docker.com/_/postgres
- This example is only for demo purposes

Liability Warning
-----------------
The contents of this repository (documents and examples) are provided “as-is” with no warrantee implied 
or otherwise about the accuracy or functionality of the examples.

You use them at your own risk. If anything results to your machine or environment or anything else as a 
result of ignoring this warning, then the fault is yours only and has nothing to do with me.
