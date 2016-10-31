#!/usr/bin/env bash
git submodule foreach git pull origin master
git add -A
git commit -m 'Update plugins'
