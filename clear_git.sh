#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Description
# Checkout dev, remove all other (local) branches. Pull dev + update submodules.
#

git checkout dev
git branch | grep -v dev | sed 's/  //g' | while read -r branch ; do
    git branch -d $branch
done
git branch
git pull
git submodule update
