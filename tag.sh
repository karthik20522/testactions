#!/bin/sh

VERSION=`git describe --tags $(git rev-list --tags --max-count=1)`

# split into array
VERSION_BITS=(${VERSION//./ })

echo "Latest version tag: $VERSION"

#get number parts and increase last one by 1
VNUM1=${VERSION_BITS[0]}
VNUM2=${VERSION_BITS[1]}
VNUM3=${VERSION_BITS[2]}

COUNT_OF_COMMIT_MSG_HAVE_SEMVER_MAJOR=`git log -1 --pretty=%B | egrep -c '\((breaking|major)\)'` # major-version-bump
COUNT_OF_COMMIT_MSG_HAVE_SEMVER_MINOR=`git log -1 --pretty=%B | egrep -c '\((feature|minor)\)'` # minor-version-bump
COUNT_OF_COMMIT_MSG_HAVE_SEMVER_PATCH=`git log -1 --pretty=%B | egrep -c '\((fix|patch|refactor)\)'` #patch-version-bump

if [ $COUNT_OF_COMMIT_MSG_HAVE_SEMVER_MAJOR -gt 0 ]; then
    VNUM1=$((VNUM1+1)) 
fi
if [ $COUNT_OF_COMMIT_MSG_HAVE_SEMVER_MINOR -gt 0 ]; then
    VNUM2=$((VNUM2+1)) 
fi
if [ $COUNT_OF_COMMIT_MSG_HAVE_SEMVER_PATCH -gt 0 ]; then
    VNUM3=$((VNUM3+1)) 
fi

# count all commits for a branch
GIT_COMMIT_COUNT=`git rev-list --count HEAD`
echo "Commit count: $GIT_COMMIT_COUNT" 
export BUILD_NUMBER=$GIT_COMMIT_COUNT

#create new tag
NEW_TAG="$VNUM1.$VNUM2.$VNUM3"

echo "Updating $VERSION to $NEW_TAG"

#only tag if commit message have version-bump
if [ $COUNT_OF_COMMIT_MSG_HAVE_SEMVER_MAJOR -gt 0 ] ||  [ $COUNT_OF_COMMIT_MSG_HAVE_SEMVER_MINOR -gt 0 ] || [ $COUNT_OF_COMMIT_MSG_HAVE_SEMVER_PATCH -gt 0 ]; then
    echo "Tagged with $NEW_TAG"
    git tag "$NEW_TAG"
fi