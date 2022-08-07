#!/bin/env python3

import os
import requests
import subprocess
import sys

git_pass = os.environ['GIT_PASS']
pull_id = os.environ['MERGE_ID']
project_id = 1
reviewer_id = 1
pull_endpoint = f"https://git.aurum.lan/api/pull-requests/{pull_id}"

r = requests.get(pull_endpoint, auth=('kay', git_pass))
project = r.json()['sourceBranch']

subprocess.run(['sudo', 'chown', '--recursive', '1000:1000', project])
os.chdir(project)
# makepkg should run sudo automatically
if subprocess.run(['makepkg', '--syncdeps', '--noconfirm']).returncode == 0:
    # remove source branch and pull request
    r = requests.post(pull_endpoint + '/delete-source-branch', auth=('kay', git_pass))
    # source branch may have been deleted, so don't fail if deletion fails
#   r = requests.delete(pull_endpoint, auth=('kay', git_pass))
#   r.raise_for_status()
    # we now have <pkg>.tar.gz
    subprocess.run(['pwd'])
    subprocess.run(['ls', '-lAh'])
else:
    print("Build failure!")
    exit(1)
