#!/bin/env python3

import os
import requests
import sys

def exit_if_failed(status):
	if os.waitstatus_to_exitcode(status) != 0:
		print("command failed")
		exit(1)


with open('packages', '') as package_file:
    for package in package_file.readlines():
        print(f'Checking package `{package}`...')
        
        package = sys.argv[1]
        project_id = 1
        reviewer_id = 1
        pull_endpoint = "https://git.aurum.lan/api/pull-requests"
        branch_endpoint = f"https://git.aurum.lan/api/repositories/{project_id}/branches"
        git_password = os.environ['GIT_PASSWORD']

        was_open = False
        r = requests.get(branch_endpoint, auth=('kay', git_password))
        if package in r.json(): # if there already is a pull request open, change there
            print("Pull request already open...")
            os.system(f'git remote set-branches origin "{package}"')
            os.system(f'git checkout {package}')
            was_open = True
        else:
            print("No old pull request found...")
            os.system(f'git switch -c {package}')

        pull_request_template = {"targetProjectId": project_id,
            "sourceProjectId": project_id,
            "targetBranch": "master",
            "sourceBranch": package,
            "title": f"Package '{package}' has changes",
            "description": "",
            "mergeStrategy": "CREATE_MERGE_COMMIT",
            "reviewerIds": [],
            "assigneeIds": []}

        login_template = f"""machine git.aurum.lan
          login kay
          password {git_password}"""

        with open('/root/.netrc', 'w') as f:
            f.write(login_template)


        # backup old package files so new ones don't overwrite
        os.system(f'mkdir -p {package}')
        os.system(f'mv {package} {package}_old')

        # download new package files
        exit_if_failed(os.system(f'wget https://aur.archlinux.org/cgit/aur.git/snapshot/{package}.tar.gz'))
        exit_if_failed(os.system(f'tar -xvf {package}.tar.gz'))

        # move new files to {package}_tmp and reset name of old files
        exit_if_failed(os.system(f'mv {package} {package}_tmp'))
        exit_if_failed(os.system(f'mv {package}_old {package}'))

        if os.waitstatus_to_exitcode(os.system(f'diff -qrN {package} {package}_tmp')) != 0:
            # in any case we are on the package branch here
            os.system(f'rm -rf {package}')
            os.system(f'mv {package}_tmp {package}')
            os.system(f'git add .')
            os.system(f'git commit -m "update {package}"')

            if not was_open: # create new branch and pull request
                os.system(f'git push -u origin {package}')
                print("Creating Pull Request...")
                r = requests.post(pull_endpoint, auth=('kay', git_password), json=pull_request_template)
                r.raise_for_status()
            else: # just update old branch
                os.system(f'git push')

