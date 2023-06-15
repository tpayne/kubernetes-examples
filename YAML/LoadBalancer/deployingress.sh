#!/bin/sh

command=$(basename $0)
direct=$(dirname $0)
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=$(pwd)

addr=""

#
# Usage
#
usage() {
	#

	while [ $# -ne 0 ]; do
		case $1 in
		-a | --addr)
			addr="$(echo ${2} | sed 's|\.|-|g')"
			shift 2
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
	echo "${command}: -a,--addr <address>"
	echo "${command}: where <address> is the ingress IP address to use"
	exit 0
}

cleanUp() {
	echo "${command}: Cleaning up the ingress..."

	(kubectl delete all --all -n logicapp-dev &&
		kubectl delete namespace logicapp-dev) >/dev/null 2>&1

	return 0
}

install() {
	echo "${command}: Deploying the ingress to ${1}..."

	cat load-balancer-solution2.yaml | sed "s|INGRESS_IPADDR|${1}|g" |
		kubectl create -f -
	if [ $? -gt 0 ]; then
		return 1
	fi

	return 0
}

usage $*

if [ "x${addr}" = "x" ]; then
	show_usage
fi

cleanUp

install "${addr}"
if [ $? -ne 0 ]; then
	echo "${command}: - Error: The installation of the ingress failed"
	exit 1
fi

exit 0
