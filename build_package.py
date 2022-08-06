#!/bin/env python3

import os
import requests
import sys

def exit_if_failed(status):
	if os.waitstatus_to_exitcode(status) != 0:
		print("command failed")
		exit(1)

if len(sys.argv) != 2:
	print("no package name passed!")
	exit(1)

package = sys.argv[1]
project_id = 1
reviewer_id = 1
endpoint = "https://git.aurum.lan/api/pull-requests"
git_password = os.environ['GIT_PASSWORD']

pull_request_template = {"targetProjectId": project_id,
	"sourceProjectId": project_id,
	"targetBranch": "master",
	"sourceBranch": package,
	"title": f"Package '{package}' has changes",
	"description": "",
	"mergeStrategy": "CREATE_MERGE_COMMIT",
	"reviewerIds": [reviewer_id],
	"asigneeIds": [reviewer_id]}

login_template = f"""machine git.aurum.lan
  login kay
  password {git_password}"""

with open('/home/root/.netrc', w) as f:
	f.write(login_template)


# backup old package files so new ones don't overwrite
os.system(f'sudo mkdir -p {package}')
os.system(f'sudo mv {package} {package}_old')

# download new package files
exit_if_failed(os.system(f'sudo wget https://aur.archlinux.org/cgit/aur.git/snapshot/{package}.tar.gz'))
exit_if_failed(os.system(f'sudo tar -xvf {package}.tar.gz'))

# move new files to {package}_tmp and reset name of old files
exit_if_failed(os.system(f'sudo mv {package} {package}_tmp'))
exit_if_failed(os.system(f'sudo mv {package}_old {package}'))

if os.waitstatus_to_exitcode(os.system(f'diff -qrN {package} {package}_tmp')) != 0:
	os.system(f'sudo git switch -c {package}')
	os.system(f'sudo rm -rf {package}')
	os.system(f'sudo mv {package}_tmp {package}')
	os.system(f'sudo git add .')
	os.system(f'sudo git commit -m "update {package}"')
	os.system(f'sudo git push -u origin {package}')

