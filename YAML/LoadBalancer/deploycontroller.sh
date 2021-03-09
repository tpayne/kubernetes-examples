#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`

namespace="ingress"
provider="default"
#
# Usage 
#
usage()
{
#

while [ $# -ne 0 ] ; do
        case $1 in
             -n | --namespace) namespace=$2
                 shift 2;;
             -p | --provider) provider=$2
                 shift 2;;            
             --debug) set -xv ; shift;;
             -?*) show_usage ; break;;
             --) shift ; break;;
             -|*) break;;
        esac
done

return 0
}

cleanUp()
{
echo "${command}: Cleaning up the controller..."

(kubectl delete all --all -n $1 && \
 kubectl delete namespace $1) > /dev/null 2>&1

return 0
}

install()
{
echo "${command}: Deploying the controller..."

kubectl create namespace $1
if [ $? -gt 0 ]; then
    return 1
fi

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
if [ $? -gt 0 ]; then
    return 1
fi

# This configuration works fine with Azure, but may need tweaking for other
# providers as some have issues... GKE for example...
# https://kubernetes.github.io/ingress-nginx/deploy/#gce-gke
# helm install ingress-nginx ingress-nginx/ingress-nginx --namespace $1

if [ "x${provider}" = "xgcp" ]; then
    # GCP also requires a 8443/tcp rule be allowed (see notes above) 
    (kubectl create clusterrolebinding cluster-admin-binding \
        --clusterrole cluster-admin \
        --user $(gcloud config get-value account)) > /dev/null 2>&1
    kubectl apply -f \
        https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/cloud/deploy.yaml
else    
    # Default working...
    helm install nginx-ingress ingress-nginx/ingress-nginx \
    	--namespace $1 \
    	--set controller.replicaCount=2 \
    	--set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    	--set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
fi

if [ $? -gt 0 ]; then
    return 1
fi

return 0
}

usage $*

# GCP uses scripts which hardcode the namespace...
if [ "x${provider}" = "xgcp" ]; then
    namespace="ingress-nginx"
fi

cleanUp ${namespace}

install ${namespace}
if [ $? -ne 0 ]; then
    echo "${command}: - Error: The installation of the controller failed"
    exit 1
fi

exit 0