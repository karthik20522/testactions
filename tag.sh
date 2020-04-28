#!/bin/bash

VERSION=`git describe --tags $(git rev-list --tags --max-count=1)`
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# split into array
VERSION_BITS=(${VERSION//./ })

echo "Latest version tag: $VERSION"

#get number parts and increase last one by 1
MAJOR=${VERSION_BITS[0]}
MINOR=${VERSION_BITS[1]}
PATCH=${VERSION_BITS[2]}

SEMVER_MAJOR=`git log -1 --pretty=%B | egrep -c '\((breaking|major)\)'` # major-version-bump
SEMVER_MINOR=`git log -1 --pretty=%B | egrep -c '\((feature|minor)\)'` # minor-version-bump
SEMVER_PATCH=`git log -1 --pretty=%B | egrep -c '\((fix|patch|refactor)\)'` #patch-version-bump

if [ $SEMVER_MAJOR -gt 0 ]; then
    MAJOR=$((MAJOR+1)) 
fi
if [ $SEMVER_MINOR -gt 0 ]; then
    MINOR=$((MINOR+1)) 
fi
if [ $SEMVER_PATCH -gt 0 ]; then
    PATCH=$((PATCH+1)) 
fi

# count all commits for a branch
GIT_COMMIT_COUNT=`git rev-list --count HEAD`
echo "Commit count: $GIT_COMMIT_COUNT" 

#create new tag
NEW_TAG="$MAJOR.$MINOR.$PATCH"

case $BRANCH in
      "master")
         NEW_TAG=${MAJOR}.$((MINOR+1)).0
         ;;
      "feature/*")
         NEW_TAG=${MAJOR}.${MINOR}.${PATCH}-${BRANCH}-${GIT_COMMIT_COUNT}
         ;;      
      *)
         >&2 echo "unsupported branch type"
         exit 1
         ;;
   esac

echo "Updating $VERSION to $NEW_TAG"

#only tag if commit message have version-bump
if [ $SEMVER_MAJOR -gt 0 ] ||  [ $SEMVER_MINOR -gt 0 ] || [ $SEMVER_PATCH -gt 0 ]; then
    echo "Tagged with $NEW_TAG"
    git tag "$NEW_TAG"
    git push --tags
fi