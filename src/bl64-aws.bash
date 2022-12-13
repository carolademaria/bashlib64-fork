#######################################
# BashLib64 / Module / Functions / Interact with AWS
#
# Version: 1.4.1
#######################################

#######################################
# Creates a SSO profile in the AWS CLI configuration file
#
# * Equivalent to aws configure sso
#
# Arguments:
#   $1: profile name
#   $2: start url
#   $3: region
#   $4: account id
#   $5: permission set
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   command exit status
#######################################

function bl64_aws_cli_create_sso() {
  bl64_dbg_lib_show_function "$@"
  local profile="${1:-${BL64_LIB_DEFAULT}}"
  local start_url="${2:-${BL64_LIB_DEFAULT}}"
  local sso_region="${3:-${BL64_LIB_DEFAULT}}"
  local sso_account_id="${4:-${BL64_LIB_DEFAULT}}"
  local sso_role_name="${5:-${BL64_LIB_DEFAULT}}"

  bl64_check_parameter 'profile' &&
    bl64_check_parameter 'start_url' &&
    bl64_check_parameter 'sso_region' &&
    bl64_check_parameter 'sso_account_id' &&
    bl64_check_parameter 'sso_role_name' &&
    bl64_check_module 'BL64_AWS_MODULE' ||
    return $?

  bl64_dbg_lib_show_info "create AWS CLI profile for AWS SSO login (${BL64_AWS_CLI_CONFIG})"
  printf '[profile %s]\n' "$profile" >"$BL64_AWS_CLI_CONFIG" &&
    printf 'sso_start_url = %s\n' "$start_url" >>"$BL64_AWS_CLI_CONFIG" &&
    printf 'sso_region = %s\n' "$sso_region" >>"$BL64_AWS_CLI_CONFIG" &&
    printf 'sso_account_id = %s\n' "$sso_account_id" >>"$BL64_AWS_CLI_CONFIG" &&
    printf 'sso_role_name = %s\n' "$sso_role_name" >>"$BL64_AWS_CLI_CONFIG"

}

#######################################
# Login to AWS using SSO
#
# * Equivalent to aws --profile X sso login
# * The SSO profile must be already created
# * SSO login requires a browser connection. The command will show the URL to open to get the one time code
#
# Arguments:
#   $1: profile name
# Outputs:
#   STDOUT: login process information
#   STDERR: command stderr
# Returns:
#   0: login ok
#   >0: failed to login
#######################################
function bl64_aws_sso_login() {
  bl64_dbg_lib_show_function "$@"
  local profile="${1:-${BL64_LIB_DEFAULT}}"

  bl64_aws_run_aws_profile \
    "$profile" \
    sso \
    login \
    --no-browser

}

#######################################
# Get current caller ARN
#
# Arguments:
#   $1: profile name
# Outputs:
#   STDOUT: ARN
#   STDERR: command stderr
# Returns:
#   0: got value ok
#   >0: failed to get
#######################################
function bl64_aws_sts_get_caller_arn() {
  bl64_dbg_lib_show_function "$@"
  local profile="${1:-${BL64_LIB_DEFAULT}}"

  # shellcheck disable=SC2086
  bl64_aws_run_aws_profile \
    "$profile" \
    $BL64_AWS_SET_FORMAT_TEXT \
    --query '[Arn]' \
    sts \
    get-caller-identity

}

#######################################
# Get file path to the SSO cached token
#
# * Token must first be generated by aws sso login
# * Token is saved in a fixed location, but with random file name
#
# Arguments:
#   $1: profile name
# Outputs:
#   STDOUT: token path
#   STDERR: command stderr
# Returns:
#   0: got value ok
#   >0: failed to get
#######################################
function bl64_aws_sso_get_token() {
  bl64_dbg_lib_show_function "$@"
  local start_url="${1:-}"
  local token_file=''

  bl64_check_module 'BL64_AWS_MODULE' &&
    bl64_check_parameter 'start_url' &&
    bl64_check_directory "$BL64_AWS_CLI_CACHE" ||
    return $?

  bl64_dbg_lib_show_info "search for sso login token (${BL64_AWS_CLI_CACHE})"
  bl64_dbg_lib_trace_start
  token_file="$(bl64_fs_find_files \
    "$BL64_AWS_CLI_CACHE" \
    "*.${BL64_AWS_DEF_SUFFIX_TOKEN}" \
    "$start_url")"
  bl64_dbg_lib_trace_stop

  if [[ -n "$token_file" && -r "$token_file" ]]; then
    echo "$token_file"
  else
    bl64_msg_show_error "$BL64_AWS_TXT_TOKEN_NOT_FOUND"
    return $BL64_LIB_ERROR_TASK_FAILED
  fi

}

#######################################
# Command wrapper for aws cli with mandatory profile
#
# * profile entry must be previously generated
#
# Arguments:
#   $1: profile name
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   command exit status
#######################################
function bl64_aws_run_aws_profile() {
  bl64_dbg_lib_show_function "$@"
  local profile="${1:-}"

  bl64_check_module 'BL64_AWS_MODULE' &&
    bl64_check_parameter 'profile' &&
    bl64_check_file "$BL64_AWS_CLI_CONFIG" ||
    return $?

  shift
  bl64_aws_run_aws \
    --profile "$profile" \
    "$@"
}

#######################################
# Command wrapper with verbose, debug and common options
#
# * Trust no one. Ignore inherited config and use explicit config
#
# Arguments:
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   command exit status
#######################################
function bl64_aws_run_aws() {
  bl64_dbg_lib_show_function "$@"
  local verbosity="$BL64_AWS_SET_OUPUT_NO_COLOR"

  bl64_check_parameters_none "$#" &&
    bl64_check_module 'BL64_AWS_MODULE' ||
    return $?

  bl64_msg_lib_verbose_enabled && verbosity=' '
  bl64_dbg_lib_command_enabled && verbosity="$BL64_AWS_SET_DEBUG"

  bl64_aws_blank_aws

  bl64_dbg_lib_show_info 'Set mandatory configuration and credential variables'
  export AWS_CONFIG_FILE="$BL64_AWS_CLI_CONFIG"
  export AWS_SHARED_CREDENTIALS_FILE="$BL64_AWS_CLI_CREDENTIALS"
  bl64_dbg_lib_show_vars 'AWS_CONFIG_FILE' 'AWS_SHARED_CREDENTIALS_FILE'

  if [[ -n "$BL64_AWS_CLI_REGION" ]]; then
    bl64_dbg_lib_show_info 'Set region as requested'
    export AWS_REGION="$BL64_AWS_CLI_REGION"
    bl64_dbg_lib_show_vars 'AWS_REGION'
  else
    bl64_dbg_lib_show_info 'Not setting region, not requested'
  fi

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_AWS_CMD_AWS" \
    $BL64_AWS_SET_INPUT_NO_PROMPT \
    $BL64_AWS_SET_OUPUT_NO_PAGER \
    $verbosity \
    "$@"
  bl64_dbg_lib_trace_stop
}

#######################################
# Remove or nullify inherited shell variables that affects command execution
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function bl64_aws_blank_aws() {
  bl64_dbg_lib_show_function

  bl64_dbg_lib_show_info 'unset inherited AWS_* shell variables'
  bl64_dbg_lib_trace_start
  unset AWS_PAGER
  unset AWS_PROFILE
  unset AWS_REGION
  unset AWS_CA_BUNDLE
  unset AWS_CONFIG_FILE
  unset AWS_DATA_PATH
  unset AWS_DEFAULT_OUTPUT
  unset AWS_DEFAULT_REGION
  unset AWS_MAX_ATTEMPTS
  unset AWS_RETRY_MODE
  unset AWS_ROLE_ARN
  unset AWS_SESSION_TOKEN
  unset AWS_ACCESS_KEY_ID
  unset AWS_CLI_AUTO_PROMPT
  unset AWS_CLI_FILE_ENCODING
  unset AWS_METADATA_SERVICE_TIMEOUT
  unset AWS_ROLE_SESSION_NAME
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SHARED_CREDENTIALS_FILE
  unset AWS_EC2_METADATA_DISABLED
  unset AWS_METADATA_SERVICE_NUM_ATTEMPTS
  unset AWS_WEB_IDENTITY_TOKEN_FILE
  bl64_dbg_lib_trace_stop

  return 0
}
