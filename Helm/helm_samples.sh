#!/bin/sh
#
# Helper script for using helm...
# ./helm_samples.sh statefulset-deployment \
#   https://raw.githubusercontent.com/tpayne/kubernetes-examples/main/Helm/statefulset-deployment

tmpFile="/tmp/tmpHelm$$.txt"

rmFile()
{
if [ -f "${1}" ]; then
    rm -f "${1}"
fi
return 0
}

helmCreate()
{
if [ -d "$1" ]; then
    return 0
fi
echo "Run a couple of helm create commands..."
helm create $1
return $?
}

helmTemplate()
{
echo "Running template..."
helm template $1 --name-template=$1 --dry-run > /dev/null 2>&1
return $?
}

helmLint()
{
echo "Running lint..."
helm lint $1 > /dev/null 2>&1
return $?
}

helmInstall()
{
rmFile "${tmpFile}"

echo "Install packages..."
helm install $1 $1/$1 > "${tmpFile}" 2>&1
if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
fi
return $?
}

helmList()
{
echo "List packages..."
helm list
return $?
}

helmUninstall()
{
echo "Uninstall packages..."
helm uninstall $1  > /dev/null 2>&1
return $?
}

helmPackage()
{
testURL "${2}/index.yaml"
if [ $? -eq 0 -a $# -lt 3 ]; then
    return 0
fi
echo "Create package..."
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

helmRepoAdd()
{
testURL "${2}/index.yaml"
if [ $? -gt 0 -o $# -eq 3 ]; then
# Add and commit your repo to git...
    gitAdd $1
    if [ $? -gt 0 ]; then
        echo "- Git add failed"
        return 1
    fi
fi
echo "Add to repo..."
# Then add index.yaml raw URL, e.g.
# https://raw.githubusercontent.com/tpayne/kubernetes-examples/main/Helm/canary-deployment/index.yaml
# helm repo add canary-deployment https://raw.githubusercontent.com/tpayne/kubernetes-examples/main/Helm/canary-deployment/
helm repo remove $1 > /dev/null 2>&1
helm repo add $1 $2 > /dev/null 2>&1
if [ $? -gt 0 ]; then
    echo "- Helm add failed"
    return 1
fi
helm repo update $1 > /dev/null 2>&1
if [ $? -gt 0 ]; then
    echo "- Helm update failed"
    return 1
fi
helm search repo $1 > /dev/null 2>&1
if [ $? -gt 0 ]; then
    echo "- Helm search failed"
    return 1
fi
return $?
}

helmPull()
{
echo "Pull package..."
(cd /tmp && helm pull $1/$1)
return $?
}

helmHistory()
{
echo "List package history..."
helm history $1
return $?
}

helmRollback()
{
echo "Rollback package..."
helm rollback $1 1 > /dev/null 2>&1
return $?
}

helmShow()
{
echo "Show package..."
helm show all $1/$1
return $?
}

helmStatus()
{
echo "Status package..."
helm status $1
return $?
}

helmCreate $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmLint $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmTemplate $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmPackage $1 $2 $3
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmRepoAdd $1 $2 $3
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmUninstall $1
sleep 120
helmInstall $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmList $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmHistory $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmShow $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmStatus $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmRollback $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
helmUninstall $1
if [ $? -gt 0 ]; then
    echo "Error: Op failed"
    exit 1
fi
exit 0
