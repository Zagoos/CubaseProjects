#!/bin/sh
for remote in `git branch -r | grep pestoduro | sed -e 's/pestoduro\///g'`; do git checkout -b $remote pestoduro/$remote; done;
for remote in `git branch -r | grep originLF | sed -e 's/originLF\///g'`; do git checkout -b $remote originLF/$remote; done;
for remote in `git branch -r | grep originPK | sed -e 's/originPK\///g'`; do git checkout -b $remote originPK/$remote; done;

for branch in `git branch`; do git checkout $branch; done;
