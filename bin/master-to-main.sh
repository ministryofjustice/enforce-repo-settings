#!/bin/bash

# Change the default branch of a github repository from "master" to "main",
# including branch protection rules.

# Inspired by:
#
#     https://www.hanselman.com/blog/EasilyRenameYourGitDefaultBranchFromMasterToMain.aspx

# Pre-requisites/assumptions
#
# * You have `hub` and `docker` installed and on the path https://github.com/github/hub
# * Current working directory has the same name as the github repository
# * You have admin access to this repository
# * A `GITHUB_TOKEN` environment variable contains a personal access token with `repo` scope

set -eu

ENFORCE_SETTINGS_CHECKOUT=~/Projects/moj/enforce-repo-settings

# Ensure we are up to date on master
git checkout master
git pull

# Rename master to main
git branch -m master main || git checkout main
git push -u origin main

# Set "main" as the default branch
# https://github.community/t/cannot-change-default-branch/13728/3
repo=$(basename $(pwd))
hub api repos/ministryofjustice/${repo} -X PATCH -F default_branch="main" > /dev/null

# Apply branch protection to `main`
docker run --rm \
  -e GITHUB_TOKEN=${GITHUB_TOKEN} \
  ministryofjustice/enforce-repository-settings:1.2 ministryofjustice ${repo}

# Delete the master branch
git push origin :master

