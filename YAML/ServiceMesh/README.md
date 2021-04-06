Service Mesh Sample
===================

This repo contains an example which shows how to install a service mesh using Kubernetes.

Service meshes are an additional network management plane that can be added to Kubernetes
to help improve the reliability and management on network messaging, load balancing, service
discovery etc.

The most common implementation is Istio which is used here.

This sample is adapted from... 
- https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install?pivots=client-operating-system-linux#:~:text=Install%20and%20use%20Istio%20in%20Azure%20Kubernetes%20Service,Uninstall%20Istio%20from%20AKS.%20...%206%20Next%20steps

Note: This example will only work with version 1.7.2. For later versions, please see...
- https://istio.io/latest/docs/setup/getting-started/
- https://istio.io/latest/docs/setup/platform-setup/azure/

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
    pod/grafana-f7bf8676f-vnj2x                 1/1     Running   0          91s
    pod/istio-ingressgateway-7c67ffddc8-b4zkg   1/1     Running   0          94s
    pod/istio-tracing-86cdb7df6-h5csx           1/1     Running   0          91s
    pod/istiod-bf956b554-fwfzg                  1/1     Running   0          104s
    pod/prometheus-5fb76b8c4d-fwkwk             1/1     Running   0          91s

    NAME                                TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                                      AGE
    service/grafana                     ClusterIP      10.0.176.199   <none>           3000/TCP                                                     91s
    service/istio-ingressgateway        LoadBalancer   10.0.229.251   52.151.208.200   15021:30482/TCP,80:32120/TCP,443:31148/TCP,15443:32424/TCP   93s
    service/istiod                      ClusterIP      10.0.56.45     <none>           15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                104s
    service/jaeger-agent                ClusterIP      None           <none>           5775/UDP,6831/UDP,6832/UDP                                   91s
    service/jaeger-collector            ClusterIP      10.0.74.15     <none>           14267/TCP,14268/TCP,14250/TCP                                91s
    service/jaeger-collector-headless   ClusterIP      None           <none>           14250/TCP                                                    90s
    service/jaeger-query                ClusterIP      10.0.103.149   <none>           16686/TCP                                                    90s
    service/prometheus                  ClusterIP      10.0.179.10    <none>           9090/TCP                                                     90s
    service/tracing                     ClusterIP      10.0.176.110   <none>           80/TCP                                                       90s
    service/zipkin                      ClusterIP      10.0.10.107    <none>           9411/TCP                                                     90s

    NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/grafana                1/1     1            1           91s
    deployment.apps/istio-ingressgateway   1/1     1            1           94s
    deployment.apps/istio-tracing          1/1     1            1           91s
    deployment.apps/istiod                 1/1     1            1           104s
    deployment.apps/prometheus             1/1     1            1           91s

    NAME                                              DESIRED   CURRENT   READY   AGE
    replicaset.apps/grafana-f7bf8676f                 1         1         1       92s
    replicaset.apps/istio-ingressgateway-7c67ffddc8   1         1         1       95s
    replicaset.apps/istio-tracing-86cdb7df6           1         1         1       92s
    replicaset.apps/istiod-bf956b554                  1         1         1       105s
    replicaset.apps/prometheus-5fb76b8c4d             1         1         1       92s

    NAME                                                       REFERENCE                         TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
    horizontalpodautoscaler.autoscaling/istio-ingressgateway   Deployment/istio-ingressgateway   3%/80%    1         5         1          94s
    horizontalpodautoscaler.autoscaling/istiod                 Deployment/istiod                 0%/80%    1         5         1          105s

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

Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete istiooperator istio-control-plane -n istio-system
    % istioctl operator remove
    % kubectl delete ns istio-system && kubectl delete ns istio-operator

References
----------
- https://istio.io/latest/docs/concepts/what-is-istio/
- https://prometheus.io
- https://www.fluentd.org
- https://docs.fluentd.org/output/elasticsearch
- https://github.com/prometheus-operator/kube-prometheus
- https://faun.pub/trying-prometheus-operator-with-helm-minikube-b617a2dccfa3
- https://www.codenotary.com/blog/kubernetes-configure-prometheus-node-exporter-to-collect-numa-information/
- https://istio.io/latest/docs/setup/getting-started/
- https://istio.io/latest/docs/examples/microservices-istio/
