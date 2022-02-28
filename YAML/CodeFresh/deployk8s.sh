#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`

group="aksagictest"
name="${group}001"
location="ukwest"
remove=0
tmpFile="/tmp/tmpFile$$.tmp"

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
             -g | --group) group=$2
                 shift 2;;
             -l | --location) location=$2
                 shift 2;;
             -d | --delete) remove=1 ; shift;;
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
echo "${command}: -g <groupName> -l <location>"
echo "${command}: where <groupName> is the resource group to use"
echo "${command}:       <location> is the location to use"

exit 0
}

cleanUp()
{
echo "${command}: Cleaning up the controller resource group..."
(az group show -n $1) > /dev/null 2>&1
if [ $? -gt 0 ]; then
    return 0
fi

(az group delete -n $1 -y) > /dev/null 2>&1
return $?
}

install()
{
rmFile "${tmpFile}"
echo "${command}: Deploying the controller \"${1}\" in \"${2}\"..."
echo "${command}: - create resource group..."
(az group create --name $1 --location $2) > /dev/null 2>&1
if [ $? -gt 0 ]; then
    return 1
fi

# dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com
exIpAddr="`dig +short myip.opendns.com @resolver1.opendns.com`"
ipAddr="`ipconfig getifaddr en0`"
echo "${command}: - create K8s system scoped to ${exIpAddr}..."
(az aks create -n "${name}" -g $1 --network-plugin azure \
    --enable-managed-identity \
    --generate-ssh-keys \
    --api-server-authorized-ip-ranges "${exIpAddr}/32") > ${tmpFile} 2>&1
if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

echo "${command}: - enable K8s system ${name} ${group}..."
(az aks get-credentials -n "${name}" -g $1 --overwrite-existing) > ${tmpFile} 2>&1
if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

return 0
}


usage $*

cleanUp ${group} ${location}
if [ $? -ne 0 -a $remove -gt 0 ]; then
    echo "${command}: - Error: The cleanup of the controller failed"
    exit 1
fi

if [ $remove -gt 0 ]; then
    exit 0
fi

install ${group} ${location}
if [ $? -ne 0 ]; then
    echo "${command}: - Error: The installation of the controller failed"
    exit 1
fi

exit 0
