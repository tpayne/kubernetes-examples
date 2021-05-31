#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`
result=0
delete=0
deploy=1
dbIP=""
lbIP=""

#
# Usage
#
usage()
{
#

while [ $# -ne 0 ] ; do
        case $1 in
            -d | --clean-up) deploy=0 ; delete=1 ; shift;;
            --debug) set -xv ; shift;;
            -?*) show_usage ; break;;
            --) shift ; break;;
            -|*) break;;
        esac
done

return 0
}

get_values()
{
echo "- Getting IP values, this may take a while as things spin up..."
while [ "x${lbIP}" = "x" ]; do
    echo "-- Waiting 10s..."
    sleep 10
    dbIP="`kubectl get service postgres-svr -n db-backend --output jsonpath='{.spec.clusterIP}'`"
    lbIP="`kubectl get service frontend-svr -n frontend --output jsonpath='{.status.loadBalancer.ingress[0].ip}'`"
done
return $?
}

deleteAll()
{
echo "Cleaning up the deployment environment..."
echo "- Delete resources..."
(kubectl delete statefulsets postgres-container -n db-backend --force) > /dev/null 2>&1
(kubectl delete all --all -n db-backend --force) > /dev/null 2>&1
(kubectl delete all --all -n frontend --force) > /dev/null 2>&1
(kubectl delete all --all -n monitor --force) > /dev/null 2>&1
(kubectl delete clusterrole fluentd --force && kubectl delete serviceaccount fluentd) > /dev/null 2>&1
(kubectl delete clusterrolebinding fluentd) > /dev/null 2>&1
echo "- Delete namespaces..."
(kubectl delete ns db-backend) > /dev/null 2>&1
(kubectl delete ns frontend) > /dev/null 2>&1
(kubectl delete ns monitor) > /dev/null 2>&1
echo "- Delete storage..."
(kubectl delete pv postgresdb-storage --force) > /dev/null 2>&1
(kubectl delete sc localstorage) > /dev/null 2>&1
return 0
}

deploy()
{
echo "Deploying environment..."
(kubectl kustomize . | kubectl create -f -)
return $?
}

usage $*
if [ $deploy -eq 1 ]; then
    deleteAll
    deploy
    result=$?
    if [ $result -gt 0 ]; then
        deleteAll
        exit $result
    fi
elif [ $delete -eq 1 ]; then
    deleteAll
    result=$?
fi

if [ $deploy -eq 1 ]; then
    get_values
    if [ $? -gt 0 ]; then
        deleteAll
        result=$?
    fi

    if [ "x${dbIP}" != "x" ]; then
        echo "-> Database server is '${dbIP}' <-"
    fi
    if [ "x${lbIP}" != "x" ]; then
        echo "-> Ingress LB is '${lbIP}' <-"
    fi
fi

echo "Done"
exit $result