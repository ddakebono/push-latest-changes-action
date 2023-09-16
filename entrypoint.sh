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

echo "Clear existing data in repo to replace with updated content"
rm -r ${REPOSITORY}/*

# COPY FILES
echo "create rsync exclude option"
_EXCLUDE_OPTION="--exclude .git"
for i in ${IGNORE//,/ }
do
    _EXCLUDE_OPTION="${_EXCLUDE_OPTION} --exclude $i"
done

echo "copy files"
rsync -a ${_EXCLUDE_OPTION} ${SOURCE_REPOSITORY}/* ./${DIRECTORY}

cd ${REPOSITORY}

mkdir ManagedButtplugIo
mkdir Yggdrasil
mkdir MessagePack-CSharp

echo "Correcting missing submodules"
git submodule add https://github.com/Er1807/ManagedButtplugIo.git
git submodule add https://github.com/TotallyWholesome/Yggdrasil.git
git submodule add https://github.com/TotallyWholesome/MessagePack-CSharp.git

echo "create commit"
git add -u :/
git commit -m "Latest changes from ${GITHUB_REPOSITORY} from ${BRANCH} branch"

echo "push to repository"
git remote set-url origin "https://${GITHUB_REPOSITORY_OWNER}:${TOKEN}@github.com/${GITHUB_REPOSITORY_OWNER}/${REPOSITORY}.git"
git push origin ${BRANCH} ${_GIT_OPTION}
