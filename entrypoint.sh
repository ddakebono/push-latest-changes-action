#!/bin/sh -l

TOKEN=$1
REPOSITORY=$2
BRANCH=$3
FORCE=$4
DIRECTORY=$5
IGNORE=$6
USEREMAIL=$7
USERNAME=$8

echo "setup git options";
_GIT_OPTION=""
if ${INPUT_FORCE}; then
    _GIT_OPTION="${_GIT_OPTION} --force"
fi

# SETUP SOURCE REPOSITORY
echo "get current directory"
SOURCE_REPOSITORY=$PWD

echo "switch to parent directory"
cd ..

# SETUP TARGET REPOSITORY
echo "setup git config"
git config --global credential.helper store
git config --global user.email "${USEREMAIL}"
git config --global user.name "${USERNAME}"

echo "clone target repository"
git clone "https://${GITHUB_REPOSITORY_OWNER}:${TOKEN}@github.com/${GITHUB_REPOSITORY_OWNER}/${REPOSITORY}.git"
cd ${REPOSITORY}

echo "get latest changes and change branches"
git fetch origin
git checkout -b ${BRANCH}

echo "create target folder if not exist"
mkdir -p ${DIRECTORY}

# COPY FILES
echo "copy files"
rsync -a ${SOURCE_REPOSITORY}/ ./${DIRECTORY}

echo "create commit"
git add -u :/
git commit -m "Latest changes from ${GITHUB_REPOSITORY} from ${BRANCH} branch"

echo "push to repository"
git remote set-url origin "https://${GITHUB_REPOSITORY_OWNER}:${TOKEN}@github.com/${GITHUB_REPOSITORY_OWNER}/${REPOSITORY}.git"
git push origin ${BRANCH} ${_GIT_OPTION}
