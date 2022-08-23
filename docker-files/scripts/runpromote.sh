#!/bin/sh

#
# This script is used to drive the promotion process. It runs yq and
# git to execute the promotion process. This promotion process involves
# copying tag values between environments in the release file
#
# The promotion can use various modes...
# - environment - which copies the "releaseFile" between environments
# - tag - which promotes specific tags between environments
# - charts - which promotes specific charts between environments
#
# The default is tag
#

command=$(basename $0)
trap 'stty echo; echo "${command} aborted"; exit' 1 2 3 15
CWD=$(pwd)

gitOpsRepo=
gitUser=
gitEmail=
gitComment=
gitToken=

gitFolder=
environment=
promoteName=
tenantName=
revision=
releaseFile="values-releaseversions.yaml"
imageTag=
pullRequestEnv=

processPull=
branchName=

debug=0
skipPromote=0

tmpFile="/tmp/tmpFile$$.tmp"
logFile="/tmp/logFile$$.txt"

rmFile() {
  if [ -f "$1" ]; then
    (rm -f "$1") >/dev/null 2>&1
  fi
  return 0
}

rmDir() {
  if [ -d "$1" ]; then
    (rm -fr "$1") >/dev/null 2>&1
  fi
  return 0
}

chkFile() {
  (test -f "$1") >/dev/null 2>&1
  return $?
}

getGitDir() {
  tmpStr="$(echo ${1} | awk '{ i = split($0,arr,"/"); print arr[i--]; }')"
  gitFolder="$(echo ${tmpStr} | awk '{str=substr($0,$0,match($0,".git")-1);printf("%s",length(str)>0 ? str : $0);}')"
  return 0
}

copyLog() {
    if [ "x${logFile}" != "x" ]; then
        cat $1 >> "${logFile}"
        return $?
    fi
    return 0
}

#
# Usage
#
usage() {
  while [ $# -ne 0 ]; do
    # GitHub actions double quote where we do not want them...
    word="$(echo "$1" | sed -e 's/^"//' -e 's/"$//')"
    case $word in
        -pr | --gitops-repo)
          gitOpsRepo=$2
          shift 2
          ;;
        -rev | --revision)
          revision=$2
          shift 2
          ;;
        -gu | --git-user)
          gitUser=$2
          shift 2
          ;;
        -gem | --git-email)
          gitEmail=$2
          shift 2
          ;;
        -gt | --git-token)
          gitToken=$2
          shift 2
          ;;
        -env | --environment)
          environment=$2
          shift 2
          ;;
        -pmenv | --promote-environment)
          promoteName=$2
          shift 2
          ;;
        -promote | --promote-type)
          promoteType="$2"
          shift 2
          ;;
        -tenant | --tenant-name)
          tenantName="$2"
          shift 2
          ;;
        -tag | --image-tag)
          imageTage="$2"
          shift 2
          ;;
        -pullenv | --pull-request-env)
          pullRequestEnv="$2"
          shift 2
          ;;
        -l | --log-file)
          logFile="$2"
          shift 2
          ;;
        --skip-promote)
          skipPromote=1
          shift
          ;;
        --debug)
          set -xv
          shift
          ;;
        --)
          shift
          ;;
        - | *) shift ;;
    esac
  done

  if [ "x${gitOpsRepo}" = "x" ]; then
    echo "${command}: - Error: GitOps repo is missing"
    show_usage
  elif [ "x${environment}" = "x" ]; then
    echo "${command}: - Error: Environment is missing"
    show_usage
  elif [ "x${promoteName}" = "x" ]; then
    echo "${command}: - Error: Promotion environment is missing"
    show_usage
  elif [ "x${gitUser}" = "x" ]; then
    echo "${command}: - Error: GitHub user is missing"
    show_usage
  elif [ "x${gitToken}" = "x" ]; then
    echo "${command}: - Error: GitHub token is missing"
    show_usage
  elif [ "x${gitEmail}" = "x" ]; then
    echo "${command}: - Error: GitHub email is missing"
    show_usage
  elif [ "x${promoteType}" = "x" ]; then
    echo "${command}: - Error: Promote type is missing"
    show_usage
  elif [ "x${tenantName}" = "x" ]; then
    echo "${command}: - Error: Tenant name is missing"
    show_usage
  fi

  return 0
}

show_usage() {
  echo "${command}: Usage..."
  echo "${command}: -pr <repoName>"
  echo "${command}: -gu <gitUser>"
  echo "${command}: -gt <gitToken>"
  echo "${command}: -env <envName>"
  echo "${command}: -rev <revision>"
  echo "${command}: -pmenv <promotionEnvName>"
  echo "${command}: -promote <promoteType>"
  echo "${command}: -tenant <tenantName>"
  echo "${command}: --debug"
  exit 1
}

cloneRepo() {
  echo "${command}: Cloning ${1}..."
  rmFile "${tmpFile}"
  cd /tmp

  getGitDir "${1}"

  export GITHUB_TOKEN=${2}

  if [ -d "${gitFolder}" ]; then
    echo "${command}: -- Deleting ${gitFolder}..."
    (rm -fr ${gitFolder}) >/dev/null 2>&1
  fi

  url=$(echo ${1} | \
    awk -v userName=${3} -v pwd=${2} \
    '{ url=substr($1,9); printf("https://%s:%s@%s",userName,pwd,url); }')

  (git clone ${url} --branch ${4}) >"${tmpFile}" 2>&1
  if [ $? -gt 0 ]; then
    cat "${tmpFile}"
    rmFile "${tmpFile}"
    return 1
  fi
  rmFile "${tmpFile}"

  return 0
}

processPullBranch() {
    branchName="promote/${2}-to-${3}/`date '+%Y-%m-%d_%H%M'`"
    echo "${command}: - Creating branch ${branchName} for promote..."
    (git checkout -b "${branchName}" && \
     git branch -u origin/main "${branchName}") > ${tmpFile} 2>&1
    if [ $? -gt 0 ]; then
      cat "${tmpFile}"
      rmFile "${tmpFile}"
      echo "${command}: Error: The Git branch operation failed"
      return 1
    fi

    cat "${tmpFile}" > "${logFile}"

    (git commit \
      -am "${4}" &&
      git push -u origin "${branchName}") > "${tmpFile}" 2>&1

    if [ $? -gt 0 ]; then
        (grep 'nothing to commit, working tree clean' "${tmpFile}") > /dev/null 2>&1
        if [ $? -gt 0 ]; then
          cat "${tmpFile}"
          cat "${tmpFile}" >> "${logFile}"
          rmFile "${tmpFile}"
          echo "${command}: Error: The Git promote operation failed"
          return 1
        else
          echo "${command}: - Git promotion complete - no changes found"
          return 0
        fi
    else
        echo "${command}: - Git promotion complete"
    fi

    createPullRequest "${2}" "${3}" "${branchName}"
    if [ $? -gt 0 ]; then
      echo "${command}: Error: The Git promote PR operation failed"
      return 1
    fi

    return 0
}

# Create a PR...
createPullRequest() {
    echo "${command}: - Creating the pull request for promotion..."

    label=“Promote-request-${2}”
    prtitle="promote-request: Promote pull-request for ${3}"
    tmpPRfile="/tmp/pr$$.md"
    cp .github/pull_request_deployment_template.md ${tmpPRfile}

    export envName="${1}"
    export promoteName="${2}"
    export branchName="${3}"

    envsubst < .github/pull_request_deployment_template.md > \
      ${tmpPRfile}

    # This login does not seem to be necessary...
    # echo "${1}" | gh auth login --with-token

    # Create the PR...
    #
    # Label creation has a bug with it atm apparently
    # and does not work...
    # (gh label create “${label}” && \
    #  gh pr create --fill \
    #    --title “${pr-title}” --label “${label}”) > ${tmpFile} 2>&1
    #
    (gh pr create --fill \
         --title "${prtitle}" \
         --body-file "${tmpPRfile}") > ${tmpFile} 2>&1

    if [ $? -gt 0 ]; then
      cat "${tmpFile}"
      echo "== The create pull request operation failed:" >> "${logFile}" 2>&1
      cat "${tmpFile}" >> "${logFile}" 2>&1
      rmFile "${tmpFile}"
      echo "${command}: Error: The Git PR operation failed"
      return 1
    fi

    echo "== The create pull request operation worked:" >> "${logFile}" 2>&1
    cat "${tmpFile}" >> "${logFile}" 2>&1
    return 0
}

processCommit() {
    echo "${command}: - Committing to the GitOps repository..."

    (git pull && \
      git commit \
       -am "${1}" && \
      git push) > "${tmpFile}" 2>&1

    if [ $? -gt 0 ]; then
      (grep 'nothing to commit, working tree clean' "${tmpFile}") > /dev/null 2>&1
      if [ $? -gt 0 ]; then
        cat "${tmpFile}"
        cat "${tmpFile}" > "${logFile}"
        rmFile "${tmpFile}"
        echo "${command}: Error: The Git promote operation failed"
        return 1
      fi
    fi

    cat "${tmpFile}" > "${logFile}"
    rmFile "${tmpFile}"
    echo "${command}: Git promotion complete"

    return 0
}

# Check branch name
checkBranchEnv() {
    rmFile /tmp/tmpProcessBranch
    if [ "x${1}" != "x" ]; then
      echo "${1}" | sed -n 1'p' | tr ',' '\n' | while read prenv;
      do
        if [ "${prenv}" = "${2}" ]; then
          touch /tmp/tmpProcessBranch
          break
        fi
      done
    fi

    if [ -f /tmp/tmpProcessBranch ]; then
      rmFile /tmp/tmpProcessBranch
      return 1
    else
      rmFile /tmp/tmpProcessBranch
      return 0
    fi
}

# Push files back to repo...
pushRepo() {
    echo "${command}: - Pushing to the GitOps repo..."

    url=$(echo ${1} | \
        awk -v userName=${2} -v \
        pwd=${3} \
        '{ url=substr($1,9); printf("https://%s:%s@%s",userName,pwd,url); }')

    (git config user.name "${2}" && \
        git config --global user.email "${4}" && \
        git remote set-url origin ${url}) > ${tmpFile} 2>&1
    if [ $? -gt 0 ]; then
        cat "${tmpFile}"
        rmFile "${tmpFile}"
        echo "${command}: Error: The Git config operation failed"
        return 1
    fi

    pushComment="Promoting components from env ${5} to ${6}"

    if [ "x${7}" != "x" ]; then
      if [ "x${7}" = "xenvironment" ]; then
        pushComment="Promoting environments from ${5} to ${6}"
      fi
    fi

    checkBranchEnv "${pullRequestEnv}" "${6}"
    if [ $? -gt 0 ]; then
      processPullBranch "${3}" "${5}" "${6}" "${pushComment}"
    else
      processCommit "${pushComment}"
    fi

    return $?
}

# Process environment promotion...
processEnv() {
    echo "${command}: - Promoting the environment chart..."
    if [ -f "GitOps-Deployments/helm/tenants/${1}/environments/${2}/${releaseFile}" ]; then
        cp GitOps-Deployments/helm/tenants/${1}/environments/${2}/${releaseFile} \
            GitOps-Deployments/helm/tenants/${1}/environments/${3}/${releaseFile}
    else
        echo "${command}: No release file detected"
        return 1
    fi

    return 0
}

# Process chart list(s)...
processChartList() {
    echo "${command}: - Promoting specific charts..."

    echo ${1} | sed -n 1'p' | tr ',' '\n' | while read word;
    do
        echo "${command}: - Processing ${word} to ${4}..."
        IMAGE_TAG=$(yq eval ".${word}.containerImage.tag" \
          GitOps-Deployments/helm/tenants/${2}/environments/${4}/${releaseFile})
        echo "${command}: -- Updating tag ${IMAGE_TAG}"
        yq eval --inplace ".${word}.containerImage.tag=\"$IMAGE_TAG\"" \
            GitOps-Deployments/helm/tenants/${2}/environments/${4}/${releaseFile}
        if [ $? -gt 0 ]; then
          echo "${command}: Error promoting chart"
          touch /tmp/processChartList.err
          break
        fi
    done

    if [ -f /tmp/processChartList.err ]; then
      rmFile /tmp/processChartList.err
      return 1
    else
      rmFile /tmp/processChartList.err
      return 0
    fi
}

# Get tag(s) modified as result of commit
getTagChangedList() {
    echo "${command}: -- Calculating tag list for ${1}..."
    (git show "${1}" -U0 \
      | grep '^[+]' \
      | grep -Ev '^(--- a/|\+\+\+ b/)' \
      | grep "tag:" \
      | awk '{ print $3; }' \
      | sed 's|"||g' \
      | sort -u) > "${2}" 2>&1
    return $?
}

# Process tag...
processTag() {
    echo "${command}: - Promoting specific tags - ${1}..."
    tagListFile=/tmp/tagList.txt
    rmFile /tmp/processTag.err
    rmFile "${tagListFile}"

    getTagChangedList "${1}" "${tagListFile}"
    if [ $? -gt 0 ]; then
      echo "${command}: Error promoting tag - cannot get the tag list"
      return 1
    fi

    (test -s "${tagListFile}") > /dev/null 2>&1 
    if [ $? -gt 0 ]; then
      echo "${command}: - Nothing to do for this commit"
      return 0
    fi
    
    cat "${tagListFile}" | sed -n 1'p' | tr ',' '\n' | sort -u | while read tag;
    do
      if [ "x${tag}" = "x" ]; then
        echo "${command}: Error promoting tag - provided commit tag not found"
        touch /tmp/processTag.err
        break
      fi

      # Yes, the yq syntax here is weird, but it works...
      yq eval "del( .[] | select(.containerImage.tag != \"${tag}\")) | keys" \
        GitOps-Deployments/helm/tenants/${2}/environments/${3}/${releaseFile} | \
        grep -v '#' | grep '\S' | cut -c 3- | \
        sort -u > ${tmpFile} 2>&1

      if [ $? -gt 0 ]; then
        echo "${command}: Error promoting tag - service name calculation failed"
        touch /tmp/processTag.err
        break
      fi

      cat ${tmpFile} | while read word;
      do
        if [ "x${word}" = "x" ]; then
          echo "${command}: Error promoting tag - provided service tag not found"
          touch /tmp/processTag.err
          break
        fi
        newTag=$(yq eval ".${word}.containerImage.tag" \
                  GitOps-Deployments/helm/tenants/${2}/environments/${3}/${releaseFile})
        echo "${command}: - Processing \"${word}\" to ${newTag}..."
        yq eval --inplace ".${word}.containerImage.tag=\"${newTag}\"" \
            GitOps-Deployments/helm/tenants/${2}/environments/${4}/${releaseFile}
        if [ $? -gt 0 ]; then
          echo "${command}: Error promoting tag"
          touch /tmp/processTag.err
          break
        fi
      done
    done

    if [ -f /tmp/processTag.err ]; then
      rmFile /tmp/processTag.err
      return 1
    else
      rmFile /tmp/processTag.err
      return 0
    fi
}

# Process file...
processFile() {
    if [ "x${1}" = "xenvironment" ]; then
        processEnv "${2}" "${3}" "${4}"
        return $?
    else
        (echo ${1} | grep ':') > /dev/null 2>&1
        if [ $? -gt 0 ]; then
          processTag "${1}" "${2}" "${3}" "${4}" "${5}"
        else
          processChartList "${1}" "${2}" "${3}" "${4}"
        fi
        return $?
    fi
    return 0
}

# Master process for the promote mechanism...
runPromote() {
    cd "/tmp/${gitFolder}"

    processFile "${promoteType}" "${tenantName}" \
                "${environment}" "${promoteName}" \
                "${imageTag}"
    if [ $? -gt 0 ]; then
        return 1
    else
        pushRepo "${gitOpsRepo}" "${gitUser}" "${gitToken}" \
                 "${gitEmail}" "${environment}" \
                 "${promoteName}" "${promoteType}"
        if [ $? -gt 0 ]; then
            return 1
        fi
    fi
    return 0
}

usage $*

echo "${command}: GitOps promotion process started..."

cloneRepo "${gitOpsRepo}" "${gitToken}" "${gitUser}" "${revision}"
if [ $? -ne 0 ]; then
    cd ${CWD}
    echo "${command}: - Error: Cloning repo failed"
    exit 1
fi

if [ ${skipPromote} -gt 0 ]; then
    echo "${command}: Skipping promotion"
    retStat=0
else
    runPromote
    retStat=$?
fi

cd ${CWD}
rmDir "/tmp/${gitFolder}"

echo "${command}: Done"
exit ${retStat}
