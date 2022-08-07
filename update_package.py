#!/bin/env python3

import os
import requests
import subprocess
import sys

def exit_if_failed(status):
	if status.returncode != 0:
		print("command failed")
		exit(1)


project_id = 1
reviewer_id = 1
pull_endpoint = "https://git.aurum.lan/api/pull-requests"
branch_endpoint = f"https://git.aurum.lan/api/repositories/{project_id}/branches"
git_password = os.environ['GIT_PASSWORD']

login_template = f"""machine git.aurum.lan
  login kay
  password {git_password}"""

with open('/root/.netrc', 'w') as f:
    f.write(login_template)

with open('packages', 'r') as package_file:
    for package in package_file.readlines():
        print(f'Checking package `{package}`...')

        was_open = False
        r = requests.get(branch_endpoint, auth=('kay', git_password))
        if package in r.json(): # if there already is a pull request open, change there
            print("Pull request already open...")
            subprocess.run(['git', 'remote', 'set-branches', 'origin', package])
            subprocess.run(['git', 'fetch', '-v', '--depth=1'])
            subprocess.run(['git', 'checkout', package])
            was_open = True
        else:
            print("No old pull request found...")
            subprocess.run(['git', 'switch', '-c', package])

        pull_request_template = {"targetProjectId": project_id,
            "sourceProjectId": project_id,
            "targetBranch": "master",
            "sourceBranch": package,
            "title": f"Package '{package}' has changes",
            "description": "",
            "mergeStrategy": "CREATE_MERGE_COMMIT",
            "reviewerIds": [],
            "assigneeIds": []}


        # backup old package files so new ones don't overwrite
        subprocess.run(['mkdir', '-p', package])
        subprocess.run(['mv', package, f'{package}_old'])

        # download new package files
        exit_if_failed(subprocess.run(['wget', f'https://aur.archlinux.org/cgit/aur.git/snapshot/{package}.tar.gz']))
        exit_if_failed(subprocess.run(['tar', '-xvf', f'{package}.tar.gz']))

        # move new files to {package}_tmp and reset name of old files
        exit_if_failed(subprocess.run(['mv', package, f'{package}_tmp']))
        exit_if_failed(subprocess.run(['mv', f'{package}_old', package]))

        if subprocess.run(['diff', '-qrN', package, f'{package}_tmp']).returncode != 0:
            # in any case we are on the package branch here
            subprocess.run(['rm', '-rf', package])
            subprocess.run(['mv', f'{package}_tmp', package])
            subprocess.run(['git', 'add', '.'])
            subprocess.run(['git', 'commit', '-m', f'update {package}'])

            if not was_open: # create new branch and pull request
                subprocess.run(['git', 'push', '-u', 'origin', package])
                print("Creating Pull Request...")
                r = requests.post(pull_endpoint, auth=('kay', git_password), json=pull_request_template)
                r.raise_for_status()
            else: # just update old branch
                subprocess.run(['git', 'push'])

