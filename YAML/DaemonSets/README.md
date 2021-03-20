DaemonSets Sample
=================

This repo contains an example which shows how to do DaemonSets using Kubernetes.

DaemonSets are used to create maintenance sets that can attach to nodes to run system
actvities like monitoring.

Dependencies
------------
Before you attempt this example, please ensure you have done the following: -
- You have installed the Kubernetes client (kubectl) 
- You have logged into a (Unix) terminal window that will allow you to do deployments to a valid K8s cluster
- You have your Kubernetes' context set to a system that you have permission to deploy to

Note: These solutions have only been tested with Kubernetes server `version 1.19.7`. 

Running the Example
-------------------
This solution uses Kubernete's Cronjob to run jobs once every 5 mins.

To run this solution please do the following steps.

You only need to do this first step if you are changing your Kubernetes configuration...

    % kubectl config get-contexts
    % kubectl config use-context <default>
    % kubectl config current-context
    
Once you have setup the client to point to the desired Kubernetes server, please run the following...

    % kubectl delete all --all -n logicapp-prod; \
        kubectl delete ns logicapp-prod; \
        kubectl create -f daemonset-monitor.yaml
    % kubectl get all -n logicapp-prod

If everything has worked as expected, then this will generate output like the following...

    mac:LoadBalancer bob$ kubectl get all -n logicapp-prod
    NAME                                     READY   STATUS    RESTARTS   AGE
    pod/logicapp-deployment-cdf4b945-2ptd5   1/1     Running   0          3m47s
    pod/logicapp-deployment-cdf4b945-dp74b   1/1     Running   0          3m47s
    pod/logicapp-deployment-cdf4b945-w2hw2   1/1     Running   0          3m47s
    pod/logicapp-deployment-cdf4b945-wwszs   1/1     Running   0          3m47s
    pod/node-monitor-55ln7                   1/1     Running   0          3m46s
    pod/node-monitor-f6jwq                   1/1     Running   0          3m46s
    pod/node-monitor-rwq88                   1/1     Running   0          3m46s

    NAME                            TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)        AGE
    service/logicapp-prod-service   LoadBalancer   10.0.8.126   52.191.35.147   80:30113/TCP   3m47s

    NAME                          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
    daemonset.apps/node-monitor   3         3         3       3            3           <none>          3m47s

    NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/logicapp-deployment   4/4     4            4           3m47s

    NAME                                           DESIRED   CURRENT   READY   AGE
    replicaset.apps/logicapp-deployment-cdf4b945   4         4         4       3m47s

To show the solution, monitor the monitor logs...

    % kubectl logs daemonset.apps/node-monitor -n logicapp-prod -f
    Found 3 pods, using pod/node-monitor-25ww4
    time="2021-03-20T15:30:08Z" level=info msg="Starting node_exporter (version=0.15.2, branch=HEAD, revision=98bc64930d34878b84a0f87dfe6e1a6da61e532d)" source="node_exporter.go:43"
    time="2021-03-20T15:30:08Z" level=info msg="Build context (go=go1.9.2, user=root@d5c4792c921f, date=20171205-14:50:53)" source="node_exporter.go:44"
    time="2021-03-20T15:30:08Z" level=info msg="Enabled collectors:" source="node_exporter.go:50"
    time="2021-03-20T15:30:08Z" level=info msg=" - loadavg" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - netdev" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - vmstat" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - filesystem" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - diskstats" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - bcache" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - zfs" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - filefd" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - conntrack" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - cpu" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - hwmon" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - edac" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - time" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - arp" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - infiniband" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - wifi" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - mdadm" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - stat" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - ipvs" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - timex" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - meminfo" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - netstat" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - xfs" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - uname" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - entropy" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - textfile" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg=" - sockstat" source="node_exporter.go:52"
    time="2021-03-20T15:30:08Z" level=info msg="Listening on :9100" source="node_exporter.go:76"

    % kubectl get pod -o wide -n logicapp-prod 
    NAME                                 READY   STATUS    RESTARTS   AGE     IP             NODE                                NOMINATED NODE   READINESS GATES
    logicapp-deployment-cdf4b945-2ptd5   1/1     Running   0          8m20s   10.240.0.119   aks-agentpool-38144429-vmss00000j   <none>           <none>
    logicapp-deployment-cdf4b945-dp74b   1/1     Running   0          8m20s   10.240.0.20    aks-agentpool-38144429-vmss00000i   <none>           <none>
    logicapp-deployment-cdf4b945-w2hw2   1/1     Running   0          8m20s   10.240.0.194   aks-agentpool-38144429-vmss00000j   <none>           <none>
    logicapp-deployment-cdf4b945-wwszs   1/1     Running   0          8m20s   10.240.0.249   aks-agentpool-38144429-vmss00000k   <none>           <none>
    node-monitor-55ln7                   1/1     Running   0          8m19s   10.240.0.226   aks-agentpool-38144429-vmss00000k   <none>           <none>
    node-monitor-f6jwq                   1/1     Running   0          8m19s   10.240.0.115   aks-agentpool-38144429-vmss00000j   <none>           <none>
    node-monitor-rwq88                   1/1     Running   0          8m19s   10.240.0.4     aks-agentpool-38144429-vmss00000i   <none>           <none>

    % kubectl describe daemonset.apps/node-monitor -n logicapp-prod 
    Name:           node-monitor
    Selector:       name=node-monitor
    Node-Selector:  <none>
    Labels:         env=prod
                    name=node-monitor
    Annotations:    deprecated.daemonset.template.generation: 1
    Desired Number of Nodes Scheduled: 3
    Current Number of Nodes Scheduled: 3
    Number of Nodes Scheduled with Up-to-date Pods: 3
    Number of Nodes Scheduled with Available Pods: 3
    Number of Nodes Misscheduled: 0
    Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
    Pod Template:
      Labels:       name=node-monitor
      Annotations:  prometheus.io/port: 9100
                    prometheus.io/scrape: true
      Containers:
       node-exporter:
        Image:      prom/node-exporter:v0.15.2
        Port:       9100/TCP
        Host Port:  9100/TCP
        Args:
          --path.procfs
          /host/proc
          --path.sysfs
          /host/sys
          --collector.filesystem.ignored-mount-points
          "^/(sys|proc|dev|host|etc)($|/)"
          --collector.textfile.directory
          /logs
        Requests:
          cpu:        150m
        Environment:  <none>
        Mounts:
          /host/dev from dev (rw)
          /host/proc from proc (rw)
          /host/sys from sys (rw)
          /logs from logs (rw)
          /rootfs from rootfs (rw)
      Volumes:
       proc:
        Type:          HostPath (bare host directory volume)
        Path:          /proc
        HostPathType:  
       dev:
        Type:          HostPath (bare host directory volume)
        Path:          /dev
        HostPathType:  
       sys:
        Type:          HostPath (bare host directory volume)
        Path:          /sys
        HostPathType:  
       logs:
        Type:          HostPath (bare host directory volume)
        Path:          /logs
        HostPathType:  
       rootfs:
        Type:          HostPath (bare host directory volume)
        Path:          /
        HostPathType:  
    Events:
      Type    Reason            Age   From                  Message
      ----    ------            ----  ----                  -------
      Normal  SuccessfulCreate  116s  daemonset-controller  Created pod: node-monitor-xvhn6
      Normal  SuccessfulCreate  116s  daemonset-controller  Created pod: node-monitor-nfkn4
      Normal  SuccessfulCreate  115s  daemonset-controller  Created pod: node-monitor-25ww4

To view various metrics, you can do the following...

    % kubectl exec daemonset.apps/node-monitor -n logicapp-prod -- wget -O- http://localhost:9100/metrics
    Connecting to localhost:9100 (127.0.0.1:9100)
    # HELP go_gc_duration_seconds A summary of the GC invocation durations.
    # TYPE go_gc_duration_seconds summary
    go_gc_duration_seconds{quantile="0"} 0.001577308
    go_gc_duration_seconds{quantile="0.25"} 0.001577308
    go_gc_duration_seconds{quantile="0.5"} 0.001577308
    go_gc_duration_seconds{quantile="0.75"} 0.001577308
    go_gc_duration_seconds{quantile="1"} 0.001577308
    go_gc_duration_seconds_sum 0.001577308
    go_gc_duration_seconds_count 1
    # HELP go_goroutines Number of goroutines that currently exist.
    # TYPE go_goroutines gauge
    go_goroutines 9
    # HELP go_info Information about the Go environment.
    # TYPE go_info gauge
    go_info{version="go1.9.2"} 1
    # HELP go_memstats_alloc_bytes Number of bytes allocated and still in use.
    # TYPE go_memstats_alloc_bytes gauge
    go_memstats_alloc_bytes 3.344656e+06
    # HELP go_memstats_alloc_bytes_total Total number of bytes allocated, even if freed.
    # TYPE go_memstats_alloc_bytes_total counter
    go_memstats_alloc_bytes_total 4.965368e+06
    # HELP go_memstats_buck_hash_sys_bytes Number of bytes used by the profiling bucket hash table.
    # TYPE go_memstats_buck_hash_sys_bytes gauge
    go_memstats_buck_hash_sys_bytes 1.443644e+06
    # HELP go_memstats_frees_total Total number of frees.
    # TYPE go_memstats_frees_total counter
    go_memstats_frees_total 26302
    # HELP go_memstats_gc_cpu_fraction The fraction of this program's available CPU time used by the GC since the program started.
    # TYPE go_memstats_gc_cpu_fraction gauge
    go_memstats_gc_cpu_fraction 1.5831045363203092e-06
    # HELP go_memstats_gc_sys_bytes Number of bytes used for garbage collection system metadata.
    # TYPE go_memstats_gc_sys_bytes gauge
    go_memstats_gc_sys_bytes 339968
    # HELP go_memstats_heap_alloc_bytes Number of heap bytes allocated and still in use.
    # TYPE go_memstats_heap_alloc_bytes gauge
    go_memstats_heap_alloc_bytes 3.344656e+06
    # HELP go_memstats_heap_idle_bytes Number of heap bytes waiting to be used.
    # TYPE go_memstats_heap_idle_bytes gauge
    go_memstats_heap_idle_bytes 1.081344e+06
    # HELP go_memstats_heap_inuse_bytes Number of heap bytes that are in use.
    # TYPE go_memstats_heap_inuse_bytes gauge
    go_memstats_heap_inuse_bytes 4.849664e+06
    # HELP go_memstats_heap_objects Number of allocated objects.
    # TYPE go_memstats_heap_objects gauge
    go_memstats_heap_objects 43707
    # HELP go_memstats_heap_released_bytes Number of heap bytes released to OS.
    # TYPE go_memstats_heap_released_bytes gauge
    go_memstats_heap_released_bytes 0
    # HELP go_memstats_heap_sys_bytes Number of heap bytes obtained from system.
    # TYPE go_memstats_heap_sys_bytes gauge
    ...

Cleaning Up
-----------
To clean up the installation, do the following...

    % kubectl delete all --all -n logicapp-prod; kubectl delete namespace logicapp-prod;
        
This will delete all the items created in your Kubernetes installation.

