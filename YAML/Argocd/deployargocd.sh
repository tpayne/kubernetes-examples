#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`
namespace="argocd"
remove=0
tmpFile="/tmp/tmpFile$$.tmp"
argoPwd=""
argoIp=""

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
             --debug) set -xv ; shift;;
             -d | --delete) remove=1 ; shift;;                
             -?*) show_usage ; break;;
             --) shift ; break;;
             -|*) break;;
        esac
done

return 0
}

testK8sAccess()
{
(kubectl get ns) > /dev/null 2>&1
return $?
}

getPwd()
{
argoPwd="`kubectl -n ${namespace} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`"
return $?
}

getArgoIp()
{
while [ "x${argoIp}" = "x" ]
do
    sleep 20
    argoIp="`kubectl get svc argocd-server -n ${namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`"
    if [ $? -ne 0 ]; then
        return 1
    fi
done
return 0
}

argoLogin()
{
sleep 30
echo "${command}: Attempting to login..."
rmFile "${tmpFile}"
# Note - This is an INSECURE login - just to test...
(argocd login ${argoIp} --insecure --username admin --password "${argoPwd}" ) \
    > "${tmpFile}"

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi
rmFile "${tmpFile}"
return 0
}

argoSetContext()
{
echo "${command}: Set default Argocd context..."
rmFile "${tmpFile}"
context="`kubectl config current-context`"
(argocd cluster add "${context}") > "${tmpFile}" 2>&1

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

rmFile "${tmpFile}"
return 0
}

cleanUp()
{
echo "${command}: Cleaning up Argocd..."

(kubectl delete all --all -n "${namespace}" && \
 kubectl delete namespace "${namespace}") > /dev/null 2>&1

return $?
}

install()
{
echo "${command}: Deploying Argocd..."
rmFile "${tmpFile}"
(kubectl create namespace "${namespace}" &&
 kubectl apply -n "${namespace}" \
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml) \
    > "${tmpFile}" 2>&1

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

(brew install argocd -q) > "${tmpFile}" 2>&1

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

# This will expose using LB, might not be preferred...
# see https://argo-cd.readthedocs.io/en/stable/getting_started/
(kubectl patch svc argocd-server -n "${namespace}" \
    -p '{"spec": {"type": "LoadBalancer"}}') \
    > "${tmpFile}" 2>&1

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

cleanUp
if [ $remove -gt 0 ]; then
    if [ $? -ne 0 ]; then
        echo "${command}: - Error: The cleanup of Argocd failed"
        exit 1
    fi
    exit 0
fi

install
if [ $? -ne 0 ]; then
    echo "${command}: - Error: The installation of Argocd failed"
    exit 1
fi

getPwd
if [ $? -ne 0 ]; then
    echo "${command}: - Error: Failed to get Argocd password"
    exit 1
fi

getArgoIp
if [ $? -ne 0 ]; then
    echo "${command}: - Error: Failed to get Argocd server IP"
    exit 1
fi

echo "${command}: - Argocd password = \"${argoPwd}\""
echo "${command}: - Argocd server IP = \"${argoIp}\""

argoLogin
if [ $? -ne 0 ]; then
    echo "${command}: - Error: Admin login test failed"
    exit 1
fi

argoSetContext
if [ $? -ne 0 ]; then
    echo "${command}: - Error: Context setting failed"
    exit 1
fi
echo "${command}: Done"
exit 0