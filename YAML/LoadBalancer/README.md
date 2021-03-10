LoadBalancing Samples
=====================

This is a couple of example Kubernetes deployment YAML files that show two approaches
to deploying applications behind a load balancering solution.

The first solution uses the native Kubernetes load balancing service solution.

The second solution uses an external load balancer solution which is installed separately.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- That you have installed Helm (helm) and the Kubernetes client (kubectl)
- Logged into a terminal window that will allow you to do deployments to a valid K8 cluster
- Have your Kubernetes context set to a system you have permission to deploy to
- This has only been tested with Kubernetes server version 1.19.7. Lower versions may require changes for solution 2, depending on the ingress support API provided. A version of this approach is given in solution 2.1 - although it has not been validated and may need additional changes for different K8s versions.

Running Solution 1
------------------
This solution uses Kubernete's default LoadBalancing endpoint support to provide load balancing
based on a port mapping solution.

To run this solution please do the following...

You only need to do this first part if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please do the following...

    % kubectl delete all --all -n logicapp-dev; \
        kubectl delete namespace logicapp-dev; \
        kubectl create -f load-balancer-solution1.yaml
    % kubectl get all -n logicapp-dev

If everything has worked, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-dev
    NAME                                           READY   STATUS    RESTARTS   AGE
    pod/logicapp-dev-deployment-5844c94467-qb5cn   2/2     Running   0          49s
    pod/logicapp-dev-deployment-5844c94467-t4r7b   2/2     Running   0          49s

    NAME                                TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)                       AGE
    service/logicapp-dev-loadbalancer   LoadBalancer   10.0.25.20   <external-ip>   80:30500/TCP,8080:31840/TCP   49s

    NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/logicapp-dev-deployment   2/2     2            2           49s

    NAME                                                 DESIRED   CURRENT   READY   AGE
    replicaset.apps/logicapp-dev-deployment-5844c94467   2         2         2       49s

To connect and use the solution, use the EXTERNAL-IP shown above and connect to...
- `<external-ip>:80`
- `<external-ip>:8080`

You can also use CURL to test the servers are up and running as well.

A default NGINX installation is deployed under port 80.

A default JENKINS installation is deployed under port 8080.

Both are accessible from the same IP (application routing is done on the port used).

Running Solution 2
------------------
This solution uses NGINX's LoadBalancing solution to provide load balancing based on a port 
mapping and path mapping based solution. It requires more manual configuration, but can provide
more functionality that the default solution.

To run this solution please do the following...

You only need to do this first part if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please do the following.
This will use Helm to install a NGINX ingress controller...

    % ./deploycontroller.sh
    % kubectl get services --namespace ingress

Notes for `deploycontroller.sh`:
- If you are using GCP, please specify the option `-p gcp`. GCP will also require some additional configuration. Please see [here](https://kubernetes.github.io/ingress-nginx/deploy/#gce-gke) for more details.

Then, once the controller has been installed do the following...

From the last command, get the EXTERNAL-IP address, then run the following...

    % ./deployingress.sh -a <EXTERNAL-IP>
    % kubectl get all -n logicapp-dev

If everything has worked, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-dev
    NAME                                                   READY   STATUS    RESTARTS   AGE
    pod/logicapp-dev-deployment-jenkins-54b9dd46cb-2xdw5   1/1     Running   0          7m52s
    pod/logicapp-dev-deployment-nginx-8447f6bdd5-jxwrb     1/1     Running   0          7m51s

    NAME                                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
    service/logicapp-dev-service-jenkins   ClusterIP   10.0.179.149   <none>        8080/TCP   7m52s
    service/logicapp-dev-service-nginx     ClusterIP   10.0.99.160    <none>        80/TCP     7m52s

    NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/logicapp-dev-deployment-jenkins   1/1     1            1           7m52s
    deployment.apps/logicapp-dev-deployment-nginx     1/1     1            1           7m52s

    NAME                                                         DESIRED   CURRENT   READY   AGE
    replicaset.apps/logicapp-dev-deployment-jenkins-54b9dd46cb   1         1         1       7m52s
    replicaset.apps/logicapp-dev-deployment-nginx-8447f6bdd5     1         1         1       7m52s

    mac:LoadBalancer bob$ kubectl get ingress  -n logicapp-dev
    NAME                           CLASS    HOSTS                         ADDRESS       PORTS   AGE
    logicapp-dev-ingress-jenkins   <none>   frontend.<IPADDRESS>.nip.io   <IPADDRESS>   80      8m57s
    logicapp-dev-ingress-nginx     <none>   frontend.<IPADDRESS>.nip.io   <IPADDRESS>   80      8m57s

    mac:LoadBalancer bob$ kubectl describe ingress logicapp-dev-ingress-jenkins logicapp-dev-ingress-nginx  \
                            -n logicapp-dev
    Name:             logicapp-dev-ingress-jenkins
    Namespace:        logicapp-dev
    Address:          <IPADDRESS>
    Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
    Rules:
      Host                            Path  Backends
      ----                            ----  --------
      frontend.<IPADDRESS>.nip.io  
                                      /svrjenkins   logicapp-dev-service-jenkins:8080 (10.244.0.100:8080)
    Annotations:                      kubernetes.io/ingress.class: nginx
                                      nginx.ingress.kubernetes.io/add-base-url: true
    Events:
      Type    Reason  Age                From                      Message
      ----    ------  ----               ----                      -------
      Normal  Sync    10m (x2 over 11m)  nginx-ingress-controller  Scheduled for sync
      Normal  Sync    10m (x2 over 11m)  nginx-ingress-controller  Scheduled for sync


    Name:             logicapp-dev-ingress-nginx
    Namespace:        logicapp-dev
    Address:          <IPADDRESS>
    Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
    Rules:
      Host                            Path  Backends
      ----                            ----  --------
      frontend.<IPADDRESS>.nip.io  
                                      /svrnginx   logicapp-dev-service-nginx:80 (10.244.0.101:80)
    Annotations:                      kubernetes.io/ingress.class: nginx
                                      nginx.ingress.kubernetes.io/rewrite-target: /$1
                                      nginx.ingress.kubernetes.io/use-regex: true
    Events:
      Type    Reason  Age                From                      Message
      ----    ------  ----               ----                      -------
      Normal  Sync    10m (x2 over 11m)  nginx-ingress-controller  Scheduled for sync
      Normal  Sync    10m (x2 over 11m)  nginx-ingress-controller  Scheduled for sync

To connect and use the solution, use the `frontend.<IPADDRESS>.nip.io` shown above and connect to...
- `frontend.<IPADDRESS>.nip.io/svrjenkins`
- `frontend.<IPADDRESS>.nip.io/svrnginx`

You can also use CURL to test the servers are up and running as well.

A default NGINX installation is deployed under port 80 using the path /svrnginx.

A default JENKINS installation is deployed under port 80 using the path /svrjenkins.

Both are accessible from the same IP (application routing is done on the path used).

Running Jenkins
---------------
If you want to play with the Jenkins solution, then you will need to do the following to get the default password

For solution 1, run the following commands to get a pod id and put it into the `<podId>` shown in the second command

    % kubectl get pods -n logicapp-dev
    % kubectl logs <podId> -c jenkins -n logicapp-dev

For solution 2, run the following commands to get the pod id with "jenkins" in its name and put it into the `<podId>` shown in the second command
    
    % kubectl get pods -n logicapp-dev 
    % kubectl logs <podId> -n logicapp-dev
    
When you have the password, you can then put this into the Jenkins login screen asking for the key.

Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete all --all -n ingress; kubectl delete namespace ingress;
    % kubectl delete all --all -n logicapp-dev; kubectl delete namespace logicapp-dev
        
This will delete all the items created in your Kubernetes installation.
