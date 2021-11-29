#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`

#
# Usage
#
usage()
{
#

while [ $# -ne 0 ] ; do
        case $1 in
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
echo "${command}: Cleaning up the ingress..."

(kubectl delete all --all -n logicapp-ndev && \
 kubectl delete namespace logicapp-ndev) > /dev/null 2>&1
(kubectl delete all --all -n logicapp-gdev && \
 kubectl delete namespace logicapp-gdev) > /dev/null 2>&1
(kubectl delete all --all -n logicapp-adev && \
 kubectl delete namespace logicapp-adev) > /dev/null 2>&1
return 0
}

install()
{
echo "${command}: Deploying the ingress samples..."

kubectl apply -f az-agic-redirect.yaml
if [ $? -gt 0 ]; then
    return 1
fi
kubectl apply -f az-agic-restapi.yaml
if [ $? -gt 0 ]; then
    return 1
fi
kubectl apply -f az-agic-simple.yaml
if [ $? -gt 0 ]; then
    return 1
fi

return 0
}

usage $*

cleanUp

install
if [ $? -ne 0 ]; then
    echo "${command}: - Error: The installation of the ingress failed"
    exit 1
fi

exit 0