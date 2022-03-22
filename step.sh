#!/bin/bash

set -eox

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
# envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.

# https://api.testproject.io/docs/v2/

echo "apk_ipa_filepath:         $apk_ipa_filepath"
echo "testproject_access_key:   $testproject_access_key"
echo "testproject_project_id:   $testproject_project_id"
echo "testproject_app_id:       $testproject_app_id"
echo "testproject_filename:     $testproject_filename"

envman run bash -c 'echo "testproject_access_key: ${testproject_access_key}"'
envman run bash -c 'echo "testproject_project_id: ${testproject_project_id}"'
envman run bash -c 'echo "testproject_app_id: ${testproject_app_id}"'
envman run bash -c 'echo "testproject_filename: ${testproject_filename}"'
envman run bash -c 'echo "BITRISE_IPA_PATH: $BITRISE_IPA_PATH"'

# if [ -z "$apk_ipa_filepath" ]; then
#   echo "Please provide the path for the IPA or APK that you wish to upload."
#   echo "For IPA it is usually \$BITRISE_IPA_PATH"
#   echo "For APK it is usually \$BITRISE_APK_PATH"
#   exit 1
# fi

# TESTPROJECT_URL_UPLOAD=$(curl -X GET "https://api.testproject.io/v2/projects/$testproject_project_id/applications/$testproject_app_id/file/upload-link" -H "accept: application/json" -H "Authorization: $testproject_access_key" | jq -r '.url')

# echo "TESTPROJECT_URL_UPLOAD='$TESTPROJECT_URL_UPLOAD'"

# TESTPROJECT_URL_UPLOAD_RESULT=$(curl -X PUT -F "upload_filename=@$apk_ipa_filepath" -L $TESTPROJECT_URL_UPLOAD)

# echo "TESTPROJECT_URL_UPLOAD_RESULT='${TESTPROJECT_URL_UPLOAD_RESULT}'"

# curl -X POST "https://api.testproject.io/v2/projects/$testproject_project_id/applications/$testproject_app_id/file" -H "accept: application/json" -H "Authorization: $testproject_access_key" -H "Content-Type: application/json" -d "{ \"fileName\": \"$testproject_filename\"}" | envman add --key TESTPROJECT_URL_UPLOAD_RESULT

# envman run bash -c 'echo "TESTPROJECT_URL_UPLOAD_RESULT: $TESTPROJECT_URL_UPLOAD_RESULT"'
