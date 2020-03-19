#!/bin/bash

echo "Script executed from: ${PWD}"

#push to git
echo "push to hugo material"
git pull origin master
git add .
git commit -m $1
git push origin

#hugo generate static file
echo "generate static site by hugo"
hugo -D -d ../p2cloudlab/

#push static web site to git
echo "push static web site to git"
cd ../p2cloudlab/
git pull origin master
git add .
git commit -m $1
git push origin