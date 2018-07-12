#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Description
# Checkout dev, remove all other (local) branches. Pull dev + update submodules.
#

printUsage() {
  echo "-f to force cleanup"
  echo "-b to create backup patch"
}


# Process args
FORCE_CLEANUP="0"
BACKUP_BEFORE="0"
while getopts fb OPTION
do
    case ${OPTION} in
        f)  FORCE_CLEANUP="1"
            ;;
        b)  BACKUP_BEFORE="1"
            ;;
        # o)  IPA_OUT="${OPTARG}"
        #     ;;
        ?)
            printUsage
            exit 1
            ;;
    esac
done

if [ "$BACKUP_BEFORE" = "1" ]; then
  echo "Extracting patch... -> ../.cleanup_backup.patch"
  # get patch from diff and save
  git diff --cached > ../.cleanup_backup.patch
fi

if [ "$FORCE_CLEANUP" = "1" ]; then
  git reset --hard
fi

git checkout dev
git branch | grep -v ' dev' | sed 's/  //g' | while read -r branch ; do
  if [ "$FORCE_CLEANUP" = "1" ]; then
    git clean -fdx # to remove all untracked files
    git branch -d $branch -f
  else
    git branch -d $branch
  fi
done

git branch
git pull
