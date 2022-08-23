#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`
namespace="argocd"
namespace_wf="argo"
namespace_evnt="argo-events"

remove=0
tmpFile="/tmp/tmpFile$$.tmp"
argoPwd=""
argoIp=""
argoWfIp=""
login=0

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
             -n-cd | --namespace-cd) namespace=$2
                 shift 2;;
             --debug) set -xv ; shift;;
             -p| --password) argoPwd=$2
                 shift 2;;
             -d | --delete) remove=1 ; shift;;                
             -l | --login) login=1; shift;;
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
argoPwd=$(kubectl get secret argocd-initial-admin-secret -n ${namespace} -o jsonpath="{.data.password}" | base64 -d; echo)
if [ "x${argoPwd}" = "x" ]; then
    return 1
fi
return 0
}

setPwd()
{
# Not supported atm
return 0
}

getArgoIp()
{
while [ "x${argoIp}" = "x" -a "x${argoWfIp}" = "x" ]
do
    sleep 20
    argoIp="`kubectl get svc argocd-server -n ${namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`"
    if [ $? -ne 0 ]; then
        return 1
    fi
    argoWfIp="`kubectl get svc argo-server -n ${namespace_wf} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`"
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

echo "${command}: - Removing Argo Workflows..."
(kubectl delete all --all -n "${namespace_wf}" && \
 kubectl delete namespace "${namespace_wf}") > /dev/null 2>&1

if [ $? -gt 0 -a ${1} -eq 0 ]; then
    return 1
fi

echo "${command}: - Removing ArgoCD..."
(kubectl delete all --all -n "${namespace}" && \
 kubectl delete namespace "${namespace}") > /dev/null 2>&1

if [ $? -gt 0 -a ${1} -eq 0 ]; then
    return 1
fi

echo "${command}: - Removing Argo events/senors/buses..."
(kubectl delete all --all -n "${namespace_evnt}" && \
 kubectl delete namespace "${namespace_evnt}") > /dev/null 2>&1

if [ $? -gt 0 -a ${1} -eq 0 ]; then
    return 1
fi

return 0
}

install()
{
echo "${command}: Deploying Argocd..."
echo "${command}: - Base Argocd..."

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

echo "${command}: - Base Argo workflows..."
rmFile "${tmpFile}"
(kubectl create namespace "${namespace_wf}" &&
 kubectl apply -n "${namespace_wf}" \
     -f https://github.com/argoproj/argo-workflows/releases/download/v3.3.1/install.yaml) \
    > "${tmpFile}" 2>&1

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

echo "${command}: - Base Argo events..."
rmFile "${tmpFile}"
(kubectl create namespace "${namespace_evnt}" &&
 kubectl apply -n "${namespace_evnt}" \
     -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/namespace-install.yaml && \
 kubectl apply -n "${namespace_evnt}" \
     -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml) \
    > "${tmpFile}" 2>&1

#  kubectl apply -n "${namespace_evnt}" \
#     -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install-validating-webhook.yaml) 

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

(argocd --help && argo --help) > /dev/null 2>&1
if [ $? -gt 0 ]; then
    (brew install argocd argo -q) > "${tmpFile}" 2>&1
    if [ $? -gt 0 ]; then
        cat "${tmpFile}"
        rmFile "${tmpFile}"
        return 1
    fi
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

(kubectl patch svc argo-server -n "${namespace_wf}" \
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

if [ $login -eq 0 ]; then
    cleanUp 1
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
echo "${command}: - Argo   server IP = \"${argoWfIp}\""

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
