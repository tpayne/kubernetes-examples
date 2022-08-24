#!/bin/sh

command=$(basename $0)
direct=$(dirname $0)
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=$(pwd)

gitToken=
namespace=argo

# Default for Docker...
registryServer=https://index.docker.io/v1/
userName=
passwd=
email=
domain=
remove=0

tmpFile="/tmp/tmpFile$$.tmp"

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
		-n | --namespace)
			namespace=$2
			shift 2
			;;
		-u | --user)
			userName=$2
			shift 2
			;;
		-p | --password)
			passwd=$2
			shift 2
			;;
		-e | --mail)
			email=$2
			shift 2
			;;
		-ud | --domain)
			domain=$2
			shift 2
			;;
		-gt | --git-token)
			gitToken=$2
			shift 2
			;;
		-r | --registeryURL)
			registryServer=$2
			shift 2
			;;
		--debug)
			set -xv
			shift
			;;
		-d | --delete)
			remove=1
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

	if [ "x${userName}" = "x" ]; then
		echo "${command}: Error: You must specify the username and password details"
		return 1
	elif [ "x${passwd}" = "x" ]; then
		echo "${command}: Error: You must specify the username and password details"
		return 1
	elif [ "x${email}" = "x" ]; then
		echo "${command}: Error: You must specify the email details"
		return 1
	elif [ "x${registryServer}" = "x" ]; then
		echo "${command}: Error: You must specify the CR registry details"
		return 1
	elif [ "x${gitToken}" = "x" ]; then
		echo "${command}: Error: You must specify the git token details"
		return 1
	fi

	return 0
}

show_usage() {
	echo "${command}:"
	echo "${command}: Usage"

	echo "${command}:     -n,--namespace <namespace> "
	echo "${command}:     -u,--user      <userName> "
	echo "${command}:     -p,--passwd    <password> "
	echo "${command}:     -e,--mail      <email> "
	echo "${command}:     -gt,----git-token <gitHubToken> "
	echo "${command}:"
	echo "${command}: where <namespace> is the namespace to use"
	echo "${command}:       <userName> is the Docker CR username to use"
	echo "${command}:       <password> is the Docker CR password to use"
	echo "${command}:       <email>    is the Docker CR email to use"
	echo "${command}:       <gitHubToken> is the Docker CR username to use"
	echo "${command}:"

	exit 0
}

testDocker() {
	echo "${command}: Test login..."

	(docker login ${registryServer} -u ${userName} -p ${passwd}) >/dev/null 2>&1
	if [ $? -gt 0 ]; then
		return 1
	fi

	return 0
}

cleanUp() {
	echo "${command}: Delete secret"
	(
		kubectl delete secret docker-config -n ${1}
		kubectl delete secret registry-creds -n ${1}
		kubectl delete secret github-token -n ${1}
	) >/dev/null 2>&1

	return 0
}

createSecret() {
	echo "${command}: Create secret"

	rmFile "${tmpFile}"

	(kubectl create secret generic github-token \
		--from-literal=token=${gitToken} --dry-run=client \
		--save-config -o yaml | kubectl apply -f - -n ${namespace}) >"${tmpFile}" 2>&1

	if [ $? -gt 0 ]; then
		cat "${tmpFile}"
		rmFile "${tmpFile}"
		return 1
	fi

	(kubectl create secret docker-registry docker-config \
		--docker-server=${registryServer} \
		--docker-username=${userName} \
		--docker-password=${passwd} \
		--docker-email=${email} \
		--dry-run=client --save-config -o yaml |
		kubectl apply -f - -n ${namespace}) >"${tmpFile}" 2>&1

	if [ $? -gt 0 ]; then
		cat "${tmpFile}"
		rmFile "${tmpFile}"
		return 1
	fi

	(kubectl create secret generic registry-creds \
		--from-literal=username=${userName} \
		--from-literal=password=${passwd} \
		--dry-run=client --save-config -o yaml |
		kubectl apply -f - -n ${namespace}) >"${tmpFile}" 2>&1

	if [ $? -gt 0 ]; then
		cat "${tmpFile}"
		rmFile "${tmpFile}"
		return 1
	fi

	rmFile "${tmpFile}"
	return 0
}

listSecret() {
	rmFile "${tmpFile}"
	(kubectl get secret/{docker-config,registry-creds,github-token} \
		-n ${namespace}) >"${tmpFile}" 2>&1

	if [ $? -gt 0 ]; then
		rmFile "${tmpFile}"
		return 1
	fi

	cat "${tmpFile}"

	rmFile "${tmpFile}"
	return 0
}

usage $*
if [ $? -ne 0 ]; then
	echo "${command}: - Usage error"
	show_usage
	exit 1
fi

testDocker
if [ $? -ne 0 ]; then
	echo "${command}: - Error: Docker Login failed. Please check access to it"
	exit 1
fi

cleanUp ${namespace}
if [ $remove -gt 0 ]; then
	if [ $? -ne 0 ]; then
		echo "${command}: - Error: The cleanup of secrets failed"
		exit 1
	fi
	exit 0
fi

createSecret
if [ $? -ne 0 ]; then
	echo "${command}: - Error: Secret creation failed"
	exit 1
fi

listSecret
if [ $? -ne 0 ]; then
	echo "${command}: - Error: Secret creation failed"
	exit 1
fi

rmFile "${tmpFile}"

exit 0
