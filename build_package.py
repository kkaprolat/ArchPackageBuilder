#!/bin/env python3

import os
import requests
import sys

if len(sys.argv) != 2:
	print("no package name passed!")
	exit(1)

package = sys.argv[1]
project_id = 1
reviewer_id = 1
endpoint = "https://git.aurum.lan/api/pull-requests"

pull_request_template = {"targetProjectId": project_id,
	"sourceProjectId": project_id,
	"targetBranch": "master",
	"sourceBranch": package,
	"title": f"Package '{package}' has changes",
	"description": "",
	"mergeStrategy": "CREATE_MERGE_COMMIT",
	"reviewerIds": [reviewer_id],
	"asigneeIds": [reviewer_id]}


# backup old package files so new ones don't overwrite
os.system(f'sudo mkdir -p {package}')
os.system(f'sudo mv {package} {package}_old')

# download new package files
os.system(f'sudo wget https://aur.archlinux.org/cgit/aur.git/snapshot/{package}.tar.gz')
os.system(f'sudo tar -xvf {package}.tar.gz')

# move new files to {package}_tmp and reset name of old files
os.system(f'sudo mv {package} {package}_tmp')
os.system(f'sudo mv {package}_old {package}')

if os.waitstatus_to_exitcode(os.system(f'diff -qrN {package} {package}_tmp')) != 0:
	os.system(f'sudo git switch -c {package}')
	os.system(f'sudo rm -rf {package}')
	os.system(f'sudo mv {package}_tmp {package}')
	os.system(f'sudo git add .')
	os.system(f'sudo git commit -m "update {package}"')
	os.system(f'sudo git push -u origin {package}')

