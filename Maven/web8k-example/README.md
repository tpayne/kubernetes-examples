Maven Spring Kubernetes Sample
==============================

This is a Maven project for building and deploying a (very) small custom spring application to a Kubernetes repo and
cluster.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- That you have installed Maven (mvn) and - optionally - Kubernetes client (kubectl)
- Logged into a terminal window that will allow you to do deployments to a valid K8 cluster
- Have your Kubernetes context set to a system you have permission to deploy to

Build Instructions
------------------
To run this sample do the following.

You only need to do this first part if you need to change your Kubernetes context...

    kubectl config get-contexts
    kubectl config use-context <default>
    kubectl config current-context
    
The following commands will build and deploy the application...

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

If you want to expose the service on a different port then add `-Djkube.enricher.jkube-service.port=80`

An Azure (ACR repo) example might be...

    mvn -Djkube.docker.registry=anazureacr.azurecr.io \
        -Djkube.enricher.jkube-service.type=LoadBalancer \
        -Djkube.enricher.jkube-service.port=80 \
        clean package k8s:build k8s:push k8s:resource k8s:deploy

This will...
- Build the app from the source
- Bake a tagged Docker (latest) image for it
- Push the image to the Azure ACR repo `anazureacr.azurecr.io`
- Create a Kubernetes deployment from the image
- Create an external LoadBalancer service for the deployment and expose it on port 80
 
Assuming everything works, you should get output like this...

    mac:web8k-example bob$ docker images
    REPOSITORY                            TAG        IMAGE ID       CREATED         SIZE
    example/web8k-example                 latest     e1ca50d680f4   2 minutes ago   526MB
    quay.io/jkube/jkube-java-binary-s2i   0.0.9      910caf82544b   7 weeks ago     509MB
    k8s.gcr.io/kube-proxy                 v1.19.3    cdef7632a242   4 months ago    118MB
    k8s.gcr.io/kube-scheduler             v1.19.3    aaefbfa906bd   4 months ago    45.7MB
    k8s.gcr.io/kube-controller-manager    v1.19.3    9b60aca1d818   4 months ago    111MB
    k8s.gcr.io/kube-apiserver             v1.19.3    a301be0cd44b   4 months ago    119MB
    k8s.gcr.io/etcd                       3.4.13-0   0369cf4303ff   6 months ago    253MB
    k8s.gcr.io/coredns                    1.7.0      bfe3a36ebd25   8 months ago    45.2MB
    docker/desktop-storage-provisioner    v1.1       e704287ce753   11 months ago   41.8MB
    docker/desktop-vpnkit-controller      v1.0       79da37e5a3aa   12 months ago   36.6MB
    k8s.gcr.io/pause                      3.2        80d28bedfe5d   12 months ago   683kB

    mac:web8k-example bob$ kubectl get deployments
    NAME            READY   UP-TO-DATE   AVAILABLE   AGE
    web8k-example   1/1     1            1           6m15s

    mac:web8k-example bob$ kubectl get services
    NAME            TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
    kubernetes      ClusterIP      10.0.0.1      <none>          443/TCP        15d
    web8k-example   LoadBalancer   10.0.95.125   20.77.152.249   80:30623/TCP   6m15s

    mac:web8k-example bob$ kubectl rollout history deployment
    deployment.apps/web8k-example 
    REVISION  CHANGE-CAUSE
    1         <none>

Testing the App
---------------
If you wish to test (or change the app) on your local system, then you can either use the 
Docker image or run the app directly using...

    mvn clean package spring-boot:run
    http://localhost:8080

Deploying the App to Azure
--------------------------
The `pom.xml` has been extended to to allow deployment to Azure as an App service. If you want
to run the deployment process, please do the following...

    mvn package azure-webapp:deploy
    
This will create an App service in the Azure Cloud you are currently authenticated against using
`az login`.

To modify the name of the deployment region and resource group, you can modify the properties 
section in the `pom.xml` as shown below...

    <properties>
        ...
        <azure.resourceGroup>test</azure.resourceGroup>
        <azure.region>westeurope</azure.region>
        ...
    </properties>

References
----------
The following references might be of interest...
- https://www.eclipse.org/jkube/docs/kubernetes-maven-plugin
- https://www.eclipse.org/jkube/docs/kubernetes-maven-plugin?fbclid=IwAR215doMPlD91r-l4OKZ0954PuWILNPGY3i7XCWaER1M2mmyVUWWhtMqXUA#registry
- https://www.eclipse.org/jkube/docs/kubernetes-maven-plugin#enrichers
- https://spring.io/guides/gs/spring-boot-kubernetes/
- https://spring.io/why-spring
- https://rohaan.medium.com/deploy-any-spring-boot-application-into-kubernetes-using-eclipse-jkube-a4167d27ee45
