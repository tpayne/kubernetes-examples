#!/bin/sh

command=$(basename $0)
direct=$(dirname $0)
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=$(pwd)

tsUid=$(date +%s)

manifestFile=""
namespace=""
engFile="/tmp/yq$$"
tagStr=".containerImage.tag"

tmpFile="/tmp/tmpFile$$.tmp"

rmFile() {
	if [ -f "$1" ]; then
		(rm -f "$1") >/dev/null 2>&1
	fi
	return 0
}

chkFile() {
	(test -r "$1" && test -f "$1") >/dev/null 2>&1
	return $?
}

#
# Usage
#
usage() {
	#

	while [ $# -ne 0 ]; do
		word="$(echo "$1" | sed -e 's/^"//' -e 's/"$//')"
		case $word in
		-n | --namespace)
			namespace=$2
			shift 2
			;;
		-f | --file)
			manifestFile=$2
			shift
			;;
		-tgs | --tag-string)
			tagStr=$2
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

	if [ "x${namespace}" = "x" ]; then
		echo "${command}: - Error: Namespace is missing"
		show_usage
	elif [ "x${manifestFile}" = "x" ]; then
		echo "${command}: - Error: Manifest file is missing"
		show_usage
	fi

	return 0
}

show_usage() {
	echo "${command}: Usage..."
	echo "${command}: -n,--namespace  <namespace>"
	echo "${command}: -f,--file       <manifestFile>"

	exit 1
}

testK8sAccess() {
	if [ $# -eq 0 ]; then
		(kubectl get ns) >/dev/null 2>&1
		return $?
	else
		(kubectl get ns "${1}") >/dev/null 2>&1
		return $?
	fi
	return 1
}

processManifest() {
	echo "${command}: Generating SBOM for ${1}..."

	tmpSbom="/tmp/tmpFile.sbom"

	# This gets the manifest list for running pods...
	# This is assumed to be a running system, else not all matches
	# will happen...
	(kubectl get pods -n "${1}" \
		-o jsonpath="{..image}" |
		tr -s '[[:space:]]' '\n' |
		sort -u) >"${tmpSbom}" 2>&1

	if [ $? -gt 0 ]; then
		cat "${tmpSbom}"
		rmFile "${tmpSbom}"
		return 1
	fi

	downloadSubEng
	if [ $? -gt 0 ]; then
		return 1
	fi

	cat "${tmpSbom}" | sort -u | grep -v "\+" |\
			awk '{$1=$1;print}' | while read line;
	do
		if [ "x${line}" != "x" ]; then
			productId="$(echo ${line} | awk '{ i = split($0,arr,"/"); printf arr[i]; }')"
			dockerImageTag="$(echo ${productId} | awk '{ i = split($0,arr,":"); printf arr[2]; }')"
			productId="$(echo ${productId} | awk '{ i = split($0,arr,":"); printf arr[1]; }')"
			if [ "x${productId}" != "x" ]; then
				imageTag=$(${engFile} eval ".${productId}${tagStr}" ${2})
				if [ "x${imageTag}" != "xnull" ]; then
					echo "${command}: - Processing ${productId} -> ${dockerImageTag}..."
					(${engFile} eval --inplace ".${productId}${tagStr}=\"${dockerImageTag}\"" ${2}) >"${tmpFile}" 2>&1
					if [ $? -gt 0 ]; then
						cat "${tmpFile}"
						rmFile "${tmpFile}"
						if [ $os != "darwin" ]; then
							rmFile "${engFile}"
						fi
						return 1
					fi
				fi
				rmFile "${tmpFile}"
			fi
		fi
	done

	if [ $os != "darwin" ]; then
		rmFile "${engFile}"
	fi

	return 0
}

downloadSubEng() {
	echo "${command}: - Getting yq for processing..."

	# Which Os?
	os=$(uname -s)
	if [ $os = "Darwin" ]; then
		os="darwin"
	else
		os="linux"
	fi

	if [ $os = "darwin" ]; then
		engFile="/usr/local/bin/yq"
		(test -e "${engFile}" && test -r "${engFile}") > /dev/null 2>&1
		if [ $? -gt 0 ]; then
			echo "Error: You need to install yq using brew"
			return 1
		fi
		return 0
	fi

	rmFile "${tmpFile}"
	rmFile "${engFile}"

	YQ_VERSION="v4.25.2"

	(curl -sSLo "${engFile}" \
		"https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" &&
		chmod +x "${engFile}") >"${tmpFile}" 2>&1

	if [ $? -gt 0 ]; then
		cat "${tmpFile}"
		rmFile "${tmpFile}"
		rmFile "${engFile}"
		return 1
	fi

	rmFile "${tmpFile}"
	return 0
}

usage $*

echo "${command}: Processing ${manifestFile}..."

chkFile "${manifestFile}"
if [ $? -gt 0 ]; then
	echo "- Error: The file specified cannot be accessed or read"
	exit 1
fi

testK8sAccess
if [ $? -gt 0 ]; then
	echo "- Error: You do not have access to a working K8s system"
	exit 1
fi

testK8sAccess "${namespace}"
if [ $? -gt 0 ]; then
	echo "- Error: You do not have access to the specified namespace"
	exit 1
fi

processManifest "${namespace}" "${manifestFile}"
if [ $? -gt 0 ]; then
	echo "- Error: Failed to process the manifest file"
	exit 1
fi

echo "${command}: Done"
exit 0
