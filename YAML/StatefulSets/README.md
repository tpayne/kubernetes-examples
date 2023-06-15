StatefulSet Sample
==================

This repo contains an example which shows how to do StatefulSets using Kubernetes.

StatefulSets are used to maintain machine names and IP addressed between pod restarts.
They will not maintain system state between restarts, so are useful for only really 
useful for fixed host IPs/names.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl) and Postgres client (psql)
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have setup the PSQL environment (e.g. `% . ./pg_env.sh`)
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`. 

Running the Example
-------------------
This solution uses Kubernete's StatefulSets to maintain a PSQL installation.

To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please run the following...

    % kubectl delete all --all -n logicapp-db; kubectl delete namespace logicapp-db; \
        kubectl delete pv postgres-01; kubectl delete pv postgres-02; \
        kubectl delete sc localstorage; \
        kubectl create -f stateful-sets.yaml
    % kubectl get all -n logicapp-db

If everything has worked as expected, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-db
    NAME                       READY   STATUS    RESTARTS   AGE
    pod/postgres-container-0   1/1     Running   0          8m13s
    pod/postgres-container-1   1/1     Running   0          8m12s

    NAME               TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
    service/postgres   LoadBalancer   10.0.251.102   52.149.199.93   5432:31889/TCP   8m14s

    NAME                                  READY   AGE
    statefulset.apps/postgres-container   2/2     8m14s

To show the solution, use the EXTERNAL_IP shown above run the following command...

    % psql -h 52.149.199.93 -U postgres
    Password for user postgres: 
    psql (13.2)
    Type "help" for help.

    postgres=# \l
                                     List of databases
        Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
    ------------+----------+----------+------------+------------+-----------------------
     postgres   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
     postgresdb | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
     template0  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                |          |          |            |            | postgres=CTc/postgres
     template1  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                |          |          |            |            | postgres=CTc/postgres
    (4 rows)

    postgres=# \c postgresdb
    You are now connected to database "postgresdb" as user "postgres".
    postgresdb=# create table test (col1 char(25), col2 char(25));
    CREATE TABLE
    postgresdb=# \d test
                       Table "public.test"
     Column |     Type      | Collation | Nullable | Default 
    --------+---------------+-----------+----------+---------
     col1   | character(25) |           |          | 
     col2   | character(25) |           |          | 

    postgresdb=# \q

Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete all --all -n logicapp-db; kubectl delete namespace logicapp-db; \
        kubectl delete pv postgres-01; kubectl delete pv postgres-02; \
        kubectl delete sc localstorage
        
This will delete all the items created in your Kubernetes installation.

Notes
-----
- https://hub.docker.com/_/postgres
- This example is only for demo purposes. IT WILL NOT WORK IN PRODUCTION ENVIRONMENTS DUE TO POSSIBLE DATA INSCONSISTENCY ISSUES
