#!/bin/bash

#=======================================
# Upload an iOS or Android file to TestProject
# Reference: https://api.testproject.io/docs/v2/
#=======================================

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e

#=======================================
# Functions
#=======================================

RESTORE='\033[0m'
RED='\033[00;31m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
GREEN='\033[00;32m'

function color_echo {
	color=$1
	msg=$2
	echo -e "${color}${msg}${RESTORE}"
}

function echo_fail {
	msg=$1
	echo
	color_echo "${RED}" "${msg}"
	exit 1
}

function echo_warn {
	msg=$1
	color_echo "${YELLOW}" "${msg}"
}

function echo_info {
	msg=$1
	echo
	color_echo "${BLUE}" "${msg}"
}

function echo_details {
	msg=$1
	echo "  ${msg}"
}

function echo_done {
	msg=$1
	color_echo "${GREEN}" "  ${msg}"
}

function validate_required_input {
	key=$1
	value=$2
	if [ -z "${value}" ] ; then
		echo_fail "[!] Missing required input: ${key}"
	fi
}

function validate_required_input_with_options {
	key=$1
	value=$2
	options=$3

	validate_required_input "${key}" "${value}"

	found="0"
	for option in "${options[@]}" ; do
		if [ "${option}" == "${value}" ] ; then
			found="1"
		fi
	done

	if [ "${found}" == "0" ] ; then
		echo_fail "Invalid input: (${key}) value: (${value}), valid options: ($( IFS=$", "; echo "${options[*]}" ))"
	fi
}

#=======================================
# Main
#=======================================

echo_details "* apk_ipa_filepath:         $apk_ipa_filepath"
echo_details "* testproject_access_key:   $testproject_access_key"
echo_details "* testproject_project_id:   $testproject_project_id"
echo_details "* testproject_app_id:       $testproject_app_id"
echo_details "* testproject_filename:     $testproject_filename"
echo_details "* testproject_job_id:     $testproject_job_id"

validate_required_input "apk_ipa_filepath" $apk_ipa_filepath
validate_required_input "testproject_access_key" $testproject_access_key
validate_required_input "testproject_project_id" $testproject_project_id
validate_required_input "testproject_app_id" $testproject_app_id
validate_required_input "testproject_filename" $testproject_filename

#=================
# Get TestProject storage url
#=================
TESTPROJECT_URL_UPLOAD=$(curl -X GET "https://api.testproject.io/v2/projects/$testproject_project_id/applications/$testproject_app_id/file/upload-link" -H "accept: application/json" -H "Authorization: $testproject_access_key" | jq -r '.url')

echo_details "TESTPROJECT_URL_UPLOAD:    $TESTPROJECT_URL_UPLOAD"

#=================
# Upload file
#=================
TESTPROJECT_URL_UPLOAD_RESULT=$(curl -v -X PUT -F "upload_filename=@$apk_ipa_filepath"  -L "$TESTPROJECT_URL_UPLOAD")

echo_details "TESTPROJECT_URL_UPLOAD_RESULT:    ${TESTPROJECT_URL_UPLOAD_RESULT}"

#=================
# Confirm application file was uploaded to TestProject storage
# http status code 200 means success
#=================
curl -X POST "https://api.testproject.io/v2/projects/$testproject_project_id/applications/$testproject_app_id/file" -H "accept: application/json" -H "Authorization: $testproject_access_key" -H "Content-Type: application/json" -d "{ \"fileName\": \"$testproject_filename\"}" | envman add --key TESTPROJECT_URL_UPLOAD_RESULT

echo_details "* TESTPROJECT_URL_UPLOAD_RESULT:     $TESTPROJECT_URL_UPLOAD_RESULT"

#=================
# Runs job if id populated
#=================

if [ -z "$testproject_job_id" ] ; then
    echo "testproject_job_id not set"
else
    curl -X POST "https://api.testproject.io/v2/projects/$testproject_project_id/jobs/$testproject_job_id/run" -H "accept: application/json" -H "Authorization: $testproject_access_key" -H "Content-Type: application/json" -d "{ }" | envman add --key TESTPROJECT_JOB_RESULT

    echo_details "* TESTPROJECT_JOB_RESULT:     $TESTPROJECT_JOB_RESULT"
fi