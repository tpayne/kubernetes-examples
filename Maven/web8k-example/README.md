Maven Spring Kubernetes Sample
==============================

This is a Maven project for building and deploying a small custom spring application to a Kubernetes repo and
cluster.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- That you have installed Maven (mvn) and - optionally - Kubernetes client (kubectl)
- Logged into a terminal window that will allow you to do deployments to a valid K8 cluster
- Have your Kubernetes context set to a system you have permission to deploy to

Build Instructions
------------------
To run this sample do the following...

    kubectl config get-contexts
    kubectl config use-context <default>
    kubectl config current-context
    mvn clean package 
    mvn [-Djkube.docker.registry=<nonDefaultCR>] k8s:build k8s:push k8s:resource k8s:deploy 
    # Optionally view the deployment details...
    docker images
    kubectl get deployments
    kubectl get services
    kubectl rollout history deployment

Where <nonDefaultCR> refers to a registry like `-Djkube.docker.registry=gcr.io/${PROJECT}`

By default the app will run as an internal ClusterIP endpoint on port 8080.

If you want to expose the service, then add `-Djkube.enricher.jkube-service.type=LoadBalancer`

If you want to expose the service on a different port then add `-Djkube.enricher.jkube-serce.port=80`

An example might be...

    mvn -Djkube.docker.registry=anazureacr.azurecr.io \
        -Djkube.enricher.jkube-service.type=LoadBalancer \
        -Djkube.enricher.jkube-service.port=80 \
        clean package k8s:build k8s:push k8s:resource k8s:deploy
    
Testing the App
---------------
If you wish to test (or change the app) on your local system, then you can either use the 
Docker image or run the app directly using...

    mvn clean package spring-boot:run
    http://localhost:8080

References
----------
The following references might be of interest...
- https://www.eclipse.org/jkube/docs/kubernetes-maven-plugin
- https://www.eclipse.org/jkube/docs/kubernetes-maven-plugin?fbclid=IwAR215doMPlD91r-l4OKZ0954PuWILNPGY3i7XCWaER1M2mmyVUWWhtMqXUA#registry
- https://www.eclipse.org/jkube/docs/kubernetes-maven-plugin#enrichers
- https://spring.io/guides/gs/spring-boot-kubernetes/
- https://spring.io/why-spring
- https://rohaan.medium.com/deploy-any-spring-boot-application-into-kubernetes-using-eclipse-jkube-a4167d27ee45
