Service Mesh Sample
===================

This repo contains an example which shows how to install a service mesh using Kubernetes.

Service meshes are an additional network management plane that can be added to Kubernetes
to help improve the reliability and management of network messaging, load balancing, service
discovery etc.

The most common implementation is Istio which is used here.

>![Service Mesh](https://istio.io/latest/docs/ops/deployment/architecture/arch.svg)

This sample is adapted from... 
- https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install?pivots=client-operating-system-linux#:~:text=Install%20and%20use%20Istio%20in%20Azure%20Kubernetes%20Service,Uninstall%20Istio%20from%20AKS.%20...%206%20Next%20steps

Note: This example will only work with version 1.7.2. For later versions, please see...
- https://istio.io/latest/docs/setup/getting-started/
- https://istio.io/latest/docs/setup/platform-setup/azure/

This sample shows how to use Istio to install...
- Virtual services (Ingress rules)
- Circuit breakers 
- Gateways

Example Dashboard
-----------------
You can invoke sample dashboard(s) like below using...

    % istioctl dashboard grafana
    
>![Sample Dashboard](https://github.com/tpayne/kubernetes-examples/blob/main/YAML/ServiceMesh/Samples/Istio_DashSample.png)

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl) 
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7` using AKS. 

Running the Example
-------------------
To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please run the following...

    % curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.7.2 sh -
    % export PATH="$PATH:`pwd`/istio-1.7.2/bin"
    % istioctl x precheck
    % sudo cp ./istio-1.7.2/bin/istioctl /usr/local/bin/istioctl
    % sudo chmod +x /usr/local/bin/istioctl

To install bash command completion, please do...

    # Generate the bash completion file and source it in your current shell
    mkdir -p ~/completions && istioctl collateral --bash -o ~/completions
    source ~/completions/istioctl.bash

    # Source the bash completion file in your .bashrc so that the command-line completions
    # are permanently available in your shell
    echo "source ~/completions/istioctl.bash" >> ~/.bashrc

Once the control client is available, you need to install the operator...

    % istioctl operator init
    % kubectl get all -n istio-operator
    NAME                                 READY   STATUS    RESTARTS   AGE
    pod/istio-operator-fb8d49976-984gm   1/1     Running   0          44s

    NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
    service/istio-operator   ClusterIP   10.0.154.178   <none>        8383/TCP   44s

    NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/istio-operator   1/1     1            1           45s

    NAME                                       DESIRED   CURRENT   READY   AGE
    replicaset.apps/istio-operator-fb8d49976   1         1         1       45s

To install the additional components, please do...

    % istioctl profile dump default
    % kubectl create ns istio-system && kubectl apply -f istio-install-aks.yaml
    % kubectl get all -n istio-system
    NAME                                        READY   STATUS    RESTARTS   AGE
    pod/grafana-f7bf8676f-vnj2x                 1/1     Running   0          89m
    pod/istio-ingressgateway-7c67ffddc8-b4zkg   1/1     Running   0          89m
    pod/istio-tracing-86cdb7df6-h5csx           1/1     Running   0          89m
    pod/istiod-bf956b554-fwfzg                  1/1     Running   0          89m
    pod/kiali-7ff5c568d7-2kgn6                  1/1     Running   0          32s
    pod/prometheus-5fb76b8c4d-fwkwk             1/1     Running   0          89m

    NAME                                TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                                      AGE
    service/grafana                     ClusterIP      10.0.176.199   <none>           3000/TCP                                                     89m
    service/istio-ingressgateway        LoadBalancer   10.0.229.251   52.151.208.200   15021:30482/TCP,80:32120/TCP,443:31148/TCP,15443:32424/TCP   89m
    service/istiod                      ClusterIP      10.0.56.45     <none>           15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                89m
    service/jaeger-agent                ClusterIP      None           <none>           5775/UDP,6831/UDP,6832/UDP                                   89m
    service/jaeger-collector            ClusterIP      10.0.74.15     <none>           14267/TCP,14268/TCP,14250/TCP                                89m
    service/jaeger-collector-headless   ClusterIP      None           <none>           14250/TCP                                                    89m
    service/jaeger-query                ClusterIP      10.0.103.149   <none>           16686/TCP                                                    89m
    service/kiali                       ClusterIP      10.0.153.43    <none>           20001/TCP                                                    33s
    service/prometheus                  ClusterIP      10.0.179.10    <none>           9090/TCP                                                     89m
    service/tracing                     ClusterIP      10.0.176.110   <none>           80/TCP                                                       89m
    service/zipkin                      ClusterIP      10.0.10.107    <none>           9411/TCP                                                     89m

    NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/grafana                1/1     1            1           89m
    deployment.apps/istio-ingressgateway   1/1     1            1           89m
    deployment.apps/istio-tracing          1/1     1            1           89m
    deployment.apps/istiod                 1/1     1            1           89m
    deployment.apps/kiali                  1/1     1            1           33s
    deployment.apps/prometheus             1/1     1            1           89m

    NAME                                              DESIRED   CURRENT   READY   AGE
    replicaset.apps/grafana-f7bf8676f                 1         1         1       89m
    replicaset.apps/istio-ingressgateway-7c67ffddc8   1         1         1       89m
    replicaset.apps/istio-tracing-86cdb7df6           1         1         1       89m
    replicaset.apps/istiod-bf956b554                  1         1         1       89m
    replicaset.apps/kiali-7ff5c568d7                  1         1         1       33s
    replicaset.apps/prometheus-5fb76b8c4d             1         1         1       89m

    NAME                                                       REFERENCE                         TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
    horizontalpodautoscaler.autoscaling/istio-ingressgateway   Deployment/istio-ingressgateway   4%/80%    1         5         1          89m
    horizontalpodautoscaler.autoscaling/istiod                 Deployment/istiod                 0%/80%    1         5         1          89m

It will take a few minutes for the install process to complete.

Logs of the install process can be accessed via the `logs` command as shown below...

    % kubectl logs -n istio-operator -l name=istio-operator -f
    2021-04-06T13:33:28.019926Z info    installer   creating resource: Service/istio-system/jaeger-query
    2021-04-06T13:33:28.065815Z info    installer   creating resource: Service/istio-system/prometheus
    2021-04-06T13:33:28.133805Z info    installer   creating resource: Service/istio-system/tracing
    2021-04-06T13:33:28.208084Z info    installer   creating resource: Service/istio-system/zipkin
    - Processing resources for Addons, Ingress gateways. Waiting for Deployment/istio-system/istio-in...
    - Processing resources for Addons, Ingress gateways. Waiting for Deployment/istio-system/grafana,...
    ✔ Ingress gateways installed
    - Processing resources for Addons. Waiting for Deployment/istio-system/grafana, Deployment/istio-...
    - Processing resources for Addons. Waiting for Deployment/istio-system/prometheus
    ✔ Addons installed

The installation is now complete.

To Enable ServiceMesh for a Namespace
-------------------------------------
To enable service mesh for a namespace, do the following...

    % kubectl label namespace <namespace> istio-injection=enabled

For example, to enable it for apps in the default namespace, do...

    % kubectl label namespace default istio-injection=enabled

Accessing the Components
------------------------
To access the addons, you can use...

    % istioctl dashboard grafana (monitoring dashboards)
    % istioctl dashboard prometheus (metrics)
    % istioctl dashboard jaeger (trace logs)
    % istioctl dashboard kiali (observability)
    % istioctl dashboard envoy <pod-name>.<namespace> (pod proxy metrics)
    
These will start a localhost web page which will use port forwarding to access data in the K8s install.

Running a Load Balancer Example
-------------------------------
A load balancer example for Istio is provided. This can be installed using...

    % kubectl delete ns logicapp-dev; kubectl create -f istio-load-balancer.yaml

To see the deployment, do...

    % kubectl get all -n logicapp-dev
    NAME                                                   READY   STATUS    RESTARTS   AGE
    pod/logicapp-dev-deployment-jenkins-54b9dd46cb-ws2mw   2/2     Running   0          14s
    pod/logicapp-dev-deployment-nginx-55858b8766-chnhs     2/2     Running   0          14s

    NAME                                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
    service/logicapp-dev-service-jenkins   ClusterIP   10.0.10.248    <none>        8080/TCP   15s
    service/logicapp-dev-service-nginx     ClusterIP   10.0.133.117   <none>        80/TCP     15s

    NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/logicapp-dev-deployment-jenkins   1/1     1            1           15s
    deployment.apps/logicapp-dev-deployment-nginx     1/1     1            1           15s

    NAME                                                         DESIRED   CURRENT   READY   AGE
    replicaset.apps/logicapp-dev-deployment-jenkins-54b9dd46cb   1         1         1       15s
    replicaset.apps/logicapp-dev-deployment-nginx-55858b8766     1         1         1       15s

The deployment is exactly the same as that shown in the LoadBalancer example.

For more information on how to use it, please see the documentation for `LoadBalancer` example
(NGINX). You can find out the Istio external-ip using the command,

    % kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

This IP can be used by CURL or your HTTP browser to access the service, e.g.

    % kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    52.151.208.255
    % open http://52.151.208.255/svrnginx
    % open http://52.151.208.255/svrjenkins

Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete ns logicapp-dev
    % kubectl delete istiooperator istio-control-plane -n istio-system
    % istioctl operator remove
    % kubectl delete ns istio-system && kubectl delete ns istio-operator

References
----------
- https://istio.io/latest/docs/concepts/what-is-istio/
- https://istio.io/latest/docs/reference/config/networking/virtual-service/
- https://istio.io/latest/docs/reference/config/networking/destination-rule/
- https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/upstream/circuit_breaking
- https://prometheus.io
- https://www.fluentd.org
- https://docs.fluentd.org/output/elasticsearch
- https://github.com/prometheus-operator/kube-prometheus
- https://faun.pub/trying-prometheus-operator-with-helm-minikube-b617a2dccfa3
- https://www.codenotary.com/blog/kubernetes-configure-prometheus-node-exporter-to-collect-numa-information/
- https://istio.io/latest/docs/setup/getting-started/
- https://istio.io/latest/docs/examples/microservices-istio/
- https://istio.io/latest/docs/reference/config/istio.analysis.v1alpha1/
- https://computingforgeeks.com/install-istio-service-mesh-in-eks-cluster/#:~:text=%20Install%20Istio%20Service%20Mesh%20in%20EKS%20Kubernetes,created%20the%20Secrets%20required%20we%20can...%20More%20
