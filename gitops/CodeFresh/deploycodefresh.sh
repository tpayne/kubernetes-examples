#!/bin/sh

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
#
CWD=`pwd`
tmpFile="/tmp/tmpFile$$.tmp"
token=
remove=0
runtime="codefresh"
context=
nginxIp=
gitToken=
repoUrl=
namespace="ingress-basic"
keep=0
pwd="ThisIsADefaultPassword001"
ssl=0

rmFile()
{
if [ $keep -gt 0 ]; then
    return 0
fi

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
             -t | --token) token=$2
                 shift 2;;
             -gt | --git-token) gitToken=$2
                 shift 2;;
             -repo | --git-repo) repoUrl=$2
                 shift 2;;
             -p | --pwd) pwd=$2
                 shift 2;;
             -d | --delete) remove=1 ; shift;;
             -k | --keep) keep=1 ; shift;;
             -ssl) ssl=1 ; shift;;
             --debug) set -xv ; shift;;
             -?*) show_usage ; break;;
             --) shift ; break;;
             -|*) break;;
        esac
done

if [ "x${token}" = "x" ]; then
    show_usage
    exit 1
elif [ "x${gitToken}" = "x" ]; then
    show_usage
    exit 1
elif [ "x${repoUrl}" = "x" ]; then
    show_usage
    exit 1
fi

return 0
}

show_usage()
{
echo "${command}: -t,--token <token>"
echo "${command}: -gt,--git-token <git-token>"
echo "${command}: -repo,--git-repo <git-repo>"
echo "${command}: where <token> is the codefresh token to use"
echo "${command}:       <git-token> is the git token to use"
echo "${command}:       <git-repo> is the gitrepo token to use"
return 0
}

testK8sAccess()
{
(kubectl get ns) > /dev/null 2>&1
return $?
}

getContext()
{
context="`kubectl config current-context`" > /dev/null 2>&1
return $?
}

getIp()
{
svc="nginx-ingress-ingress-nginx-controller"
while [ "x${nginxIp}" = "x" ]
do
    sleep 20
    nginxIp="`kubectl get svc "${svc}" -n ${namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`"
    if [ $? -ne 0 ]; then
        return 1
    fi
done
return 0
}

cleanUp()
{
echo "${command}: Cleaning up the installation..."
echo "${command}: - logs are in ${tmpFile}..."
(cf runtime uninstall ${runtime} --git-token ${gitToken} \
    --silent --context "${context}" --force) > ${tmpFile} 2>&1

#cf config delete-context ${runtime}
return 0
}

installBin()
{
rmFile "${tmpFile}"
(cd /tmp && curl -L --output - \
    https://github.com/codefresh-io/cli-v2/releases/latest/download/cf-darwin-amd64.tar.gz | \
    tar zx && mv ./cf-darwin-amd64 /usr/local/bin/cf \
    && cf version) > "${tmpFile}" 2>&1

if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

(brew install argocd argocd-autopilot) > "${tmpFile}" 2>&1
(brew tap codefresh-io/cli && brew install codefresh) > "${tmpFile}" 2>&1
(cf config create-context ${runtime} --api-key ${token}) > "${tmpFile}" 2>&1
rmFile "${tmpFile}"
return 0   
}

install()
{
echo "${command}: Deploying Codefresh (this will take a while)..."
echo "${command}: - logs are in ${tmpFile}..."

(cf config create-context ${runtime} --api-key ${token}) > "${tmpFile}" 2>&1

if [ $? -gt 0 ]; then
    grep "already exists" "${tmpFile}" > /dev/null 2>&1
    if [ $? -gt 0 ]; then
        cat "${tmpFile}"
        rmFile "${tmpFile}"
        return 1
    fi
fi

if [ $ssl -gt 0 ]; then
    echo "${command}: Deploying SSL..."
    (cf runtime install ${runtime} --context "${context}" \
        --ingress-host https://${nginxIp} \
        --silent --repo ${repoUrl} \
        --git-token ${gitToken}) > "${tmpFile}" 2>&1
else    
    (cf runtime install ${runtime} --context "${context}" --ingress-host http://${nginxIp} \
        --silent --insecure-ingress-host \
        --repo ${repoUrl} --git-token ${gitToken}) > "${tmpFile}" 2>&1
fi
if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi

rmFile "${tmpFile}"
return 0
}

usage $*

testK8sAccess
if [ $? -ne 0 ]; then
    echo "${command}: - Error: K8s server is not available. Please check access to it"
    exit 1
fi

getContext
if [ $? -ne 0 ]; then
    echo "${command}: - Error: Unable to get current K8s context"
    exit 1
fi

installBin
if [ $? -ne 0 ]; then
    echo "${command}: - Error: The installation of Codefresh binaries failed"
    exit 1
fi

cleanUp 
if [ $remove -gt 0 ]; then
    if [ $? -ne 0 ]; then
        echo "${command}: - Error: The cleanup of Codefresh failed"
        exit 1
    fi
    exit 0
fi

getIp
if [ $? -ne 0 ]; then
    echo "${command}: - Error: Unable to get current ingress IP"
    exit 1
fi

install
if [ $? -ne 0 ]; then
    echo "${command}: - Error: The installation of Codefresh failed"
    exit 1
fi


echo "${command}: Done"
exit 0