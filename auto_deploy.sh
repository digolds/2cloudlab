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

#small images
cp -a ../p2cloudlab/images/. ../p2cloudlab/small_images/
optimize-images ../p2cloudlab/small_images/

#push static web site to git
echo "push static web site to git"
cd ../p2cloudlab/
git pull origin master
git add .
git commit -m $1
git push origin