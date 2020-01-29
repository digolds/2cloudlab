#!/bin/bash

#push to git
git add .
git commit -m $1
git push origin

#hugo generate static file
hugo -D -d ../p2cloudlab/

#push static web site to git
cd ../p2cloudlab/
git add .
git commit -m $1
git push origin