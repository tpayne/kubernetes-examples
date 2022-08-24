#!/bin/sh

command=$(basename $0)
direct=$(dirname $0)
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=$(pwd)

group="aksagictest"
name="${group}001"
location="ukwest"
remove=0
tmpFile="/tmp/tmpFile$$.tmp"
authIps="107.21.238.215/32,18.209.185.91/32,18.215.207.215/32,18.233.130.31/32,18.210.174.176/32,23.20.5.235/32,3.232.154.67/32,34.192.31.53/32,34.193.111.98/32,34.195.17.245/32,34.196.33.69/32,34.198.38.4/32,34.200.163.76/32,44.238.236.43/32,44.234.209.117/32,44.239.141.205/32,44.228.66.171/32,44.238.167.159/32,44.237.63.217/32,192.30.252.0/22,185.199.108.0/22,140.82.112.0/20,143.55.64.0/20"
rmFile() {
	if [ -f "$1" ]; then
		(rm -f "$1") >/dev/null 2>&1
	fi
	return 0
}

#
# Usage
#
usage() {
	#

	while [ $# -ne 0 ]; do
		case $1 in
		-g | --group)
			group=$2
			shift 2
			;;
		-l | --location)
			location=$2
			shift 2
			;;
		-d | --delete)
			remove=1
			shift
			;;
		--debug)
			set -xv
			shift
			;;
		-?*)
			show_usage
			break
			;;
		--)
			shift
			break
			;;
		- | *) break ;;
		esac
	done

	return 0
}

show_usage() {
	echo "${command}: -g <groupName> -l <location>"
	echo "${command}: where <groupName> is the resource group to use"
	echo "${command}:       <location> is the location to use"

	exit 0
}

cleanUp() {
	echo "${command}: Cleaning up the controller resource group..."
	(az group show -n $1) >/dev/null 2>&1
	if [ $? -gt 0 ]; then
		return 0
	fi

	(az group delete -n $1 -y) >/dev/null 2>&1
	return $?
}

getIp() {
	rgName="MC_${group}_${name}_${location}"
	echo "${command}: Getting gateway ip address for ${name} ${group}..."
	rmFile "${tmpFile}"

	# For some reason, this seems to be the only way to get the shell to protect the quotes correctly...
	echo "(az network lb show -n kubernetes -g \"${rgName}\" --query 'frontendIpConfigurations[].publicIpAddress.id' -o tsv)" |
		sh >${tmpFile} 2>&1
	publicIpId="$(cat ${tmpFile})"
	xipAddr="$(az network public-ip show --ids \"${publicIpId}\" --query "{ ipAddress: ipAddress }" --out tsv)"
	rmFile "${tmpFile}"
	echo "${command}: - Gateway IP address is \"${xipAddr}\""
	return 0
}

install() {
	rmFile "${tmpFile}"
	echo "${command}: Deploying the controller \"${1}\" in \"${2}\"..."
	echo "${command}: - create resource group..."
	(az group create --name $1 --location $2) >/dev/null 2>&1
	if [ $? -gt 0 ]; then
		return 1
	fi

	# dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com
	exIpAddr="$(dig +short myip.opendns.com @resolver1.opendns.com)"
	ipAddr="$(ipconfig getifaddr en0)"
	echo "${command}: - create K8s system scoped to ${exIpAddr}..."
	(az aks create -n "${name}" -g $1 --network-plugin azure \
		--enable-managed-identity \
		--generate-ssh-keys \
		--location "${2}" \
		--api-server-authorized-ip-ranges "${exIpAddr}/32","${authIps}") >${tmpFile} 2>&1
	if [ $? -gt 0 ]; then
		cat "${tmpFile}"
		rmFile "${tmpFile}"
		return 1
	fi

	echo "${command}: - enable K8s system ${name} ${group}..."
	(az aks get-credentials -n "${name}" -g $1 --overwrite-existing) >${tmpFile} 2>&1
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

getIp
if [ $? -ne 0 ]; then
	echo "${command}: - Error: Failed to get IP address"
	exit 1
fi

exit 0
