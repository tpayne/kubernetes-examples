#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`

projectId=""
clusterId=""
zone=""
region=""
tmpFile="/tmp/clustergcp$$.log"
delete=0

#
# Usage
#
usage()
{
#

while [ $# -ne 0 ] ; do
        case $1 in
            -c | --cluster) clusterId="$2"
                shift 2;;
            -p | --project) projectId="$2"
                shift 2;;
            -z | --zone) zone="$2"
                shift 2;;
            -d | --clean-up) delete=1 ; shift;;
            --debug) set -xv ; shift;;
            -?*) show_usage ; break;;
            --) shift ; break;;
            -|*) break;;
        esac
done

if [ "x${clusterId}" = "x" ]; then
    show_usage
elif [ "x${projectId}" = "x" ]; then
    show_usage
elif [ "x${zone}" = "x" ]; then
    show_usage
fi

region="`echo ${zone} | rev | cut -c 3- | rev`"
return 0
}

show_usage()
{
echo "${command}: -c <clusterId> -p <projectId> -z <zone>"
exit 0
}

cleanUp()
{
echo "${command}: Cleaning up the cluster..."

(gcloud container clusters delete "${1}" --zone "${2}" --quiet) > /dev/null 2>&1

return 0
}


create_cluster()
{
(gcloud container --project "${1}" clusters create "${2}" --zone "${3}" --no-enable-basic-auth --cluster-version "1.19.9-gke.1400" --release-channel "regular" --machine-type "n1-standard-2" --image-type "UBUNTU_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "20" --preemptible --num-nodes "6" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/${1}/global/networks/default" --subnetwork "projects/${1}/regions/${4}/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,CloudRun,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --tags "gitops" --node-locations "${3}") \
    > ${tmpFile} 2>&1

return $?
}

install_creds()
{
(gcloud container clusters get-credentials "${1}" --zone "${2}") > /dev/null 2>&1
return $?
}

usage $*

echo "Creating cluster '${clusterId}' in project '${projectId}' (zone ${zone}/${region})"

cleanUp "${clusterId}" "${zone}"
if [ $delete -gt 0 ]; then
    exit 0
fi
echo "Creating cluster ${clusterId}..."
create_cluster "${projectId}" "${clusterId}" "${zone}" "${region}"
if [ $? -gt 0 ]; then
   echo "Error: Cluster creation failed (please see ${tmpFile})"
   exit 1
else
   echo "Cluster created"
fi

install_creds "${clusterId}" "${zone}"
if [ $? -gt 0 ]; then
   echo "Error: Cluster get-credentials failed"
   exit 1
fi

exit 0
