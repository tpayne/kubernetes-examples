#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`

namespace="falco"
remove=0
custom_rules=0
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
echo "${command}: Cleanup Falco..."
(helm uninstall falco -n $1 && kubectl delete ns $1) > /dev/null 2>&1
return $?
}

installcustom()
{
echo "${command}: Deploying custom rules..."
(helm upgrade falco falcosecurity/falco -f custom_rules.yaml -n $1) > /dev/null 2>&1
return $?
}

install()
{
echo "${command}: Deploying Falco..."

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
(helm upgrade --create-namespace --install -n $1 falco \
    falcosecurity/falco --set falco.jsonOutput=true --set \
    fakeEventGenerator.enabled=false) > /dev/null 2>&1

if [ $? -gt 0 ]; then
    return 1
fi

return 0
}

usage $*

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
elif [ $custom_rules -gt 0 ]; then
    sleep 120
    installcustom ${namespace}
    if [ $? -ne 0 ]; then
        echo "${command}: - Error: The installation of Falco failed"
        exit 1
    fi
fi

exit 0
