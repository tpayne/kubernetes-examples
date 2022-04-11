#!/bin/sh
#
# Helper script for using helm...
# ./helm_samples.sh statefulset-deployment \
#   https://raw.githubusercontent.com/tpayne/kubernetes-examples/main/Helm/statefulset-deployment

command=`basename $0`
direct=`dirname $0`
trap 'stty echo; echo "${command} aborted"; cd ${CWD}; exit' 1 2 3 15
#
CWD=`pwd`

tmpFile="/tmp/tmpHelm$$.txt"

create=0
lint=0
addRepo=0
package=0
install=0
uninstall=0
info=0
rollback=0
override=0
pull=0
expand=0
test=0

repoName=""
dirName=""
gitRepo=""
indexURL=""
namespace=""
#
# Usage
#
usage()
{
#

while [ $# -ne 0 ] ; do
        case $1 in
             -n | --name) repoName=$2
                 shift 2;;
             -wd | --directory) dirName=$2
                 shift 2;;
             -gr | --git-repo) gitRepo=$2
                 shift 2;;
             -iurl | --index-url) indexURL=$2
                 shift 2;;
             -ns | --namespace) namespace=$2
                 shift 2;;
             -p | --package) package=1 ; shift;;
             -g | --get | --pull) pull=1 ; shift;;
             -c | --create) create=1 ; shift;;
             -l | --lint) lint=1 ; shift;;
             -a | --add-repo) addRepo=1 ; shift;;
             -i | --install) install=1 ; shift;;
             -u | --uninstall) uninstall=1 ; shift;;
             -v | --verbose) info=1 ; shift;;
             -r | --rollback) rollback=1 ; shift;;
             --force) override=1 ; shift;;
             -e | --expand) expand=1 ; shift;;
             -t | --test) test=1 ; shift;;
             --debug) set -xv ; shift;;
             -?*) show_usage ; break;;
             --) shift ; break;;
             -|*) break;;
        esac
done

if [ "x${dirName}" != "x" ]; then
    if [ ! -d "${dirName}" ]; then
        echo "${command}: Error: directory does not exist"
        return 1
    fi
else
    dirName=${CWD}
fi

if [ "x${repoName}" = "x" ]; then
    echo "${command}: Error: Repo name must be specified"
    return 1
fi

if [ "x${indexURL}" = "x" ]; then
    if [ $addRepo -gt 0 -o $package -gt 0 ]; then
        echo "${command}: Error: Index URL must be specified"
        return 1
    fi
fi

return 0
}


rmFile()
{
if [ -f "${1}" ]; then
    rm -f "${1}"
fi
return 0
}

# This will create a helm chart
helmCreate()
{
if [ -d "$1" ]; then
    return 0
fi
echo "${command}: Creating a helm module..."
helm create $1
return $?
}

# This will expand a chart to show what the expanded text looks like
helmTemplate()
{
echo "${command}: Running template..."
helm template $1 --name-template=$1 --dry-run > "${tmpFile}" 2>&1
retStat=$?
if [ $expand -gt 0 -a $retStat -eq 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
fi
rmFile "${tmpFile}"
return $retStat
}

# This will lint a chart for syntax errors
helmLint()
{
echo "${command}: Running lint..."
helm lint $1 > "${tmpFile}" 2>&1
retStat=$?
if [ $retStat -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi
rmFile "${tmpFile}"
return $retStat
}

# This will test a helm chart (running test YAML against the deployment to check it)
helmTest()
{
echo "${command}: Running test..."
if [ "x$2" = "x" ]; then
    helm test $1 > "${tmpFile}" 2>&1
    retStat=$?
else
    helm test $1 -n $2 > "${tmpFile}" 2>&1
    retStat=$?
fi    
if [ $retStat -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi
rmFile "${tmpFile}"
return $retStat
}

# This will install a chart
helmInstall()
{
rmFile "${tmpFile}"

echo "${command}: Installing $1..."
helm install $1 $1/$1 > "${tmpFile}" 2>&1
retStat=$?
if [ $retStat -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi
return $retStat
}

# This will uninstall a chart
helmUninstall()
{
echo "${command}: Uninstalling $1..."
helm uninstall $1  > /dev/null 2>&1
return $?
}

# This will create a helm package
helmPackage()
{
testURL "${2}/index.yaml"
if [ $? -eq 0 -a $3 -eq 0 ]; then
    return 0
fi
echo "${command}: Create package..."
cd $1
helm package .
if [ $? -gt 0 ]; then
    return 1
fi
cd ..
helm repo index $1
return $?
}

testURL()
{
wget -O- $1 > /dev/null 2>&1
return $?
}

gitAdd()
{
git add $1
if [ $? -gt 0 ]; then
    return 1
fi
git commit -m "Adding package"
if [ $? -gt 0 ]; then
    return 1
fi
git pull
if [ $? -gt 0 ]; then
    return 1
fi
git push
return $?
}

# This will add package to a repo and refresh the repo definitions
helmRepoAdd()
{
rmFile "${tmpFile}"
testURL "${2}/${1}/index.yaml"
if [ $? -gt 0 -o $3 -gt 0 ]; then
    echo "${command}: Add to repo..."
    # Add and commit your repo to git...
    gitAdd $1
    if [ $? -gt 0 ]; then
        echo "- Git add failed"
        return 1
    fi
fi
echo "${command}: Add Helm repo..."
helm repo update > /dev/null 2>&1
# Then add index.yaml raw URL, e.g.
# https://raw.githubusercontent.com/tpayne/kubernetes-examples/main/Helm/canary-deployment/index.yaml
# helm repo add canary-deployment https://raw.githubusercontent.com/tpayne/kubernetes-examples/main/Helm/canary-deployment/
helm repo remove $1 > /dev/null 2>&1
helm repo add $1 $2/$1 > "${tmpFile}" 2>&1
if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    echo "- Helm add failed"
    return 1
fi
helm repo update $1 > /dev/null 2>&1
if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    echo "- Helm update failed"
    return 1
fi
echo "${command}: Search repo for contents..."
helm search repo $1 > "${tmpFile}" 2>&1
if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    echo "- Helm search failed"
    return 1
fi
cat "${tmpFile}"
rmFile "${tmpFile}"
return $?
}

# This will pull a helm package from a repo
helmPull()
{
echo "${command}: Pull package..."
helm pull $1/$1
return $?
}

# This will display the package history
helmHistory()
{
echo "${command}: List package history..."
helm history $1
return $?
}

# This will rollback a chart
helmRollback()
{
echo "${command}: Rollback package..."
helm rollback $1 1 > /dev/null 2>&1
return $?
}

# This will show a package 
helmShow()
{
echo "${command}: Show package..."
helm show all $1/$1
return $?
}

# This will display a package status
helmStatus()
{
echo "${command}: Status package..."
helm status $1
return $?
}

# This will list a known packages
helmList()
{
echo "${command}: List packages..."
helm list
return $?
}

usage $*
if [ $? -gt 0 ]; then
    exit 1
fi

cd ${dirName}

if [ $create -gt 0 ]; then
    helmCreate ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $lint -gt 0 ]; then
    helmLint ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
    helmTemplate ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $expand -gt 0 ]; then
    helmTemplate ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $package -gt 0 ]; then
    helmPackage ${repoName} ${indexURL} ${override}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $addRepo -gt 0 ]; then
    helmRepoAdd ${repoName} ${indexURL} ${override}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $install -gt 0 ]; then
    helmUninstall ${repoName}
    if [ $? -eq 0 ]; then
        sleep 120
    fi    
    helmInstall ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $test -gt 0 ]; then
    helmTest ${repoName} ${namespace}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $rollback -gt 0 ]; then
    helmRollback ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $info -gt 0 ]; then
    helmList ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
    helmHistory ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
    helmShow ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
    helmStatus ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $pull -gt 0 ]; then
    helmPull ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

if [ $uninstall -gt 0 ]; then
    helmUninstall ${repoName}
    if [ $? -gt 0 ]; then
        echo "${command}: Error: Op failed"
        cd ${CWD}
        exit 1
    fi
fi

cd ${CWD}
exit 0
