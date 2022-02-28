#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`

namespace="ingress-basic"
provider="default"
tmpFile="/tmp/tmpFile$$.tmp"
nginxIp=
remove=0

rmFile()
{
if [ -f "$1" ]; then
    (rm -f "$1") > /dev/null 2>&1
fi
return 0
}
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
             -d | --delete) remove=1 ; shift;;
             -?*) show_usage ; break;;
             --) shift ; break;;
             -|*) break;;
        esac
done

return 0
}

show_usage()
{
echo "${command}: -n,--namespace <namespace>"
echo "${command}: where <namespace> is the namespace to use"
exit 0
}

cleanUp()
{
echo "${command}: Cleaning up the controller..."

(kubectl delete all --all -n $1 && \
 kubectl delete namespace $1 && 
 kubectl delete clusterroles nginx-ingress-ingress-nginx) > /dev/null 2>&1

return 0
}

testK8sAccess()
{
(kubectl get ns) > /dev/null 2>&1
return $?
}

getIp()
{
svc="nginx-ingress-ingress-nginx-controller"
while [ "x${nginxIp}" = "x" ]
do
    sleep 20
    nginxIp="`kubectl get svc "${svc}" -n ${namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`"
    if [ $? -ne 0 ]; then
        return 1
    fi
done
return 0
}

install()
{
rmFile "${tmpFile}"
echo "${command}: Deploying the controller..."

(helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
    helm repo update) > "${tmpFile}" 2>&1
if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

# This configuration works fine with Azure, but may need tweaking for other
# providers as some have issues... GKE for example...
# https://kubernetes.github.io/ingress-nginx/deploy/#gce-gke
# helm install ingress-nginx ingress-nginx/ingress-nginx --namespace $1

if [ "x${provider}" = "xgcp" ]; then
    # GCP also requires a 8443/tcp rule be allowed (see notes above)
    (kubectl create namespace $1) > /dev/null 2>&1
    if [ $? -gt 0 ]; then
        return 1
    fi 
    (kubectl create clusterrolebinding cluster-admin-binding \
        --clusterrole cluster-admin \
        --user $(gcloud config get-value account)) > /dev/null 2>&1
    (kubectl apply -f \
        https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml) > "${tmpFile}" 2>&1
elif [ "x${provider}" = "xaws" ]; then
    (kubectl create namespace $1) > /dev/null 2>&1
    if [ $? -gt 0 ]; then
        return 1
    fi 
    (kubectl apply -f \
        https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/aws/deploy.yaml) > "${tmpFile}" 2>&1
else    
    # Default working...
    (helm install nginx-ingress ingress-nginx/ingress-nginx \
    	--namespace $1 --create-namespace \
    	--set controller.replicaCount=2 \
    	--set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    	--set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux) > "${tmpFile}" 2>&1
fi

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi
rmFile "${tmpFile}"
return 0
}

usage $*

testK8sAccess
if [ $? -ne 0 ]; then
    echo "${command}: - Error: K8s server is not available. Please check access to it"
    exit 1
fi

# GCP uses scripts which hardcode the namespace...
if [ "x${provider}" = "xgcp" ]; then
    namespace="ingress-nginx"
fi


cleanUp ${namespace}
if [ $remove -gt 0 ]; then
    if [ $? -ne 0 ]; then
        echo "${command}: - Error: The cleanup of Ingress controller failed"
        exit 1
    fi
    exit 0
fi

install ${namespace}
if [ $? -ne 0 ]; then
    echo "${command}: - Error: The installation of the controller failed"
    exit 1
fi

getIp
if [ $? -ne 0 ]; then
    echo "${command}: - Error: Getting Ingress IP failed"
    exit 1
fi

echo "${command}: Controller IP is ${nginxIp}"

rmFile "${tmpFile}"

exit 0
