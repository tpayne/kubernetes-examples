#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`

namespace="falco"
remove=0
custom_rules=0
sidekick=0
tmpFile="/tmp/tmpdeployfalco.$$"
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
             -d | --delete) remove=1 ; shift;;
             -c | --custom-rules) custom_rules=1 ; shift;;
             -s | --side-kick) sidekick=1 ; shift;;
             --debug) set -xv ; shift;;
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
echo "${command}: - Cleanup Falco..."
(kubectl delete ns kubeless && true) > /dev/null 2>&1
(kubectl delete ns $1) > /dev/null 2>&1
return $?
}

installcustom()
{
echo "${command}: - Deploying custom rules..."
(helm upgrade falco falcosecurity/falco -f custom_rules.yaml -n $1) > /dev/null 2>&1
return $?
}

installkubeless()
{
echo "${command}: - Deploying Kubeless..."
kubeRel=$(curl -s https://api.github.com/repos/kubeless/kubeless/releases/latest \
    | grep tag_name | cut -d '"' -f 4)

if [ "x${kubeRel}" = "x" ]; then
    kubeRel="v1.0.8"
fi

(kubectl create ns kubeless && \
    kubectl apply --force=true --overwrite=true -n kubeless -f \
    https://github.com/vmware-archive/kubeless/releases/download/$kubeRel/kubeless-$kubeRel.yaml) \
    > ${tmpFile} 2>&1

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rm -f "${tmpFile}"
    return 1
fi
rm -f "${tmpFile}"
return 0
}

installsidekick()
{
echo "${command}: - Deploying Sidekick..."
(helm install falcosidekick falcosecurity/falcosidekick \
    --set config.kubeless.namespace=kubeless \
    -n $1) > ${tmpFile} 2>&1

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rm -f "${tmpFile}"
    return 1
fi
rm -f "${tmpFile}"
return 0
}

install()
{
echo "${command}: - Deploying Falco..."

(kubectl create namespace $1) > /dev/null 2>&1
if [ $? -gt 0 ]; then
    return 1
fi

(helm repo add falcosecurity https://falcosecurity.github.io/charts && helm repo update) > /dev/null 2>&1
if [ $? -gt 0 ]; then
    return 1
fi

# helm install falco -n falco falcosecurity/falco
# helm upgrade falco falcosecurity/falco -f custom_rules.yaml -n falco
if [ $sidekick -eq 0 ]; then
    (helm upgrade --create-namespace --install -n $1 falco \
        falcosecurity/falco --set falco.jsonOutput=true \
        --set falco.jsonOutput=true --set falco.httpOutput.enabled=true \
        --set fakeEventGenerator.enabled=false) > ${tmpFile} 2>&1
else
    (helm upgrade --create-namespace --install -n $1 falco \
        falcosecurity/falco --set falco.jsonOutput=true \
        --set falco.jsonOutput=true --set falco.httpOutput.enabled=true \
        --set falco.httpOutput.url=http://falcosidekick:2801 \
        --set fakeEventGenerator.enabled=false) > ${tmpFile} 2>&1
fi

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rm -f "${tmpFile}"
    return 1
fi
rm -f "${tmpFile}"
return 0
}

usage $*

echo "${command}: Running"

cleanUp ${namespace}
if [ $? -ne 0 -a $remove -gt 0 ]; then
    echo "${command}: - Error: The cleanup of Falco failed"
    exit 1
fi

if [ $remove -gt 0 ]; then
    exit 0
fi

install ${namespace}
if [ $? -ne 0 ]; then
    echo "${command}: - Error: The installation of Falco failed"
    exit 1
fi

if [ $sidekick -gt 0 ]; then
    echo "${command}: - Let Falco infra spin-up..."
    sleep 120
    installsidekick ${namespace}
    if [ $? -ne 0 ]; then
        echo "${command}: - Error: The installation of Falco failed"
        exit 1
    fi
    installkubeless
    if [ $? -ne 0 ]; then
        echo "${command}: - Error: The installation of Falco failed"
        exit 1
    fi
fi

if [ $custom_rules -gt 0 ]; then
    echo "${command}: - Let Falco infra spin-up..."
    sleep 120
    installcustom ${namespace}
    if [ $? -ne 0 ]; then
        echo "${command}: - Error: The installation of Falco failed"
        exit 1
    fi
fi

echo "${command}: - Package list..."
(helm list -n ${namespace} --short)
echo "${command}: Done"

rm -f "${tmpFile}"

exit 0
