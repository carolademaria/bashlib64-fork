#######################################
# BashLib64 / Module / Functions / Manage Version Control System
#######################################

#######################################
# GIT CLI wrapper with verbose, debug and common options
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
function bl64_vcs_run_git() {
  bl64_dbg_lib_show_function "$@"
  local debug="$BL64_VCS_SET_GIT_QUIET"

  bl64_check_module 'BL64_VCS_MODULE' &&
    bl64_check_parameters_none "$#" &&
    bl64_check_command "$BL64_VCS_CMD_GIT" || return $?

  bl64_vcs_blank_git

  bl64_dbg_lib_show_info "current path: $(pwd)"
  if bl64_dbg_lib_command_enabled; then
    debug=''
    export GIT_TRACE='2'
  else
    export GIT_TRACE='0'
  fi

  export GIT_CONFIG_NOSYSTEM='0'
  export GIT_AUTHOR_EMAIL='nouser@nodomain'
  export GIT_AUTHOR_NAME='bl64_vcs_run_git'

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_VCS_CMD_GIT" \
    $debug \
    $BL64_VCS_SET_GIT_NO_PAGER \
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
function bl64_vcs_blank_git() {
  bl64_dbg_lib_show_function

  bl64_dbg_lib_show_info 'unset inherited GIT_* shell variables'
  bl64_dbg_lib_trace_start
  unset GIT_TRACE
  unset GIT_CONFIG_NOSYSTEM
  unset GIT_AUTHOR_EMAIL
  unset GIT_AUTHOR_NAME
  bl64_dbg_lib_trace_stop

  return 0
}

#######################################
# Clone GIT branch
#
# * File ownership is set to the current user
# * Destination is created if not existing
# * Single branch
# * Depth = 1
#
# Arguments:
#   $1: URL to the GIT repository
#   $2: destination path where the repository will be created
#   $3: branch name. Default: main
# Outputs:
#   STDOUT: git output
#   STDERR: git stderr
# Returns:
#   n: git exit status
#######################################
function bl64_vcs_git_clone() {
  bl64_dbg_lib_show_function "$@"
  local source="${1}"
  local destination="${2}"
  local branch="${3:-main}"

  bl64_check_parameter 'source' &&
    bl64_check_parameter 'destination' &&
    bl64_check_command "$BL64_VCS_CMD_GIT" ||
    return $?

  bl64_fs_create_dir "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "$destination" || return $?

  bl64_msg_show_lib_subtask "$_BL64_VCS_TXT_CLONE_REPO ($source)"

  # shellcheck disable=SC2164
  cd "$destination"

  # shellcheck disable=SC2086
  bl64_vcs_run_git \
    clone \
    --depth 1 \
    --single-branch \
    --branch "$branch" \
    "$source"
}

#######################################
# Clone partial GIT repository (sparse checkout)
#
# * File ownership is set to the current user
# * Destination is created if not existing
#
# Arguments:
#   $1: URL to the GIT repository
#   $2: destination path where the repository will be created
#   $3: branch name. Default: main
#   $4: include pattern list. Field separator: space
# Outputs:
#   STDOUT: git output
#   STDERR: git stderr
# Returns:
#   n: git exit status
#######################################
function bl64_vcs_git_sparse() {
  bl64_dbg_lib_show_function "$@"
  local source="${1}"
  local destination="${2}"
  local branch="${3:-main}"
  local pattern="${4}"
  local item=''
  local -i status=0

  bl64_check_command "$BL64_VCS_CMD_GIT" &&
    bl64_check_parameter 'source' &&
    bl64_check_parameter 'destination' &&
    bl64_check_parameter 'pattern' || return $?

  bl64_fs_create_dir "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "$destination" || returnn $?

  # shellcheck disable=SC2164
  cd "$destination"

  bl64_dbg_lib_show_info 'detect if current git supports sparse-checkout option'
  if bl64_os_match "${BL64_OS_DEB}-9" "${BL64_OS_DEB}-10" "${BL64_OS_UB}-18" "${BL64_OS_UB}-20" "${BL64_OS_OL}-7" "${BL64_OS_CNT}-7"; then
    bl64_dbg_lib_show_info 'git sparse-checkout not supported. Using alternative method'
    # shellcheck disable=SC2086
    bl64_vcs_run_git init &&
      bl64_vcs_run_git remote add origin "$source" &&
      bl64_vcs_run_git config core.sparseCheckout true &&
      {
        IFS=' '
        for item in $pattern; do echo "$item" >>'.git/info/sparse-checkout'; done
        unset IFS
      } &&
      bl64_vcs_run_git pull --depth 1 origin "$branch"
  else
    bl64_dbg_lib_show_info 'git sparse-checkout is supported'
    # shellcheck disable=SC2086
    bl64_vcs_run_git init &&
      bl64_vcs_run_git sparse-checkout set &&
      {
        IFS=' '
        for item in $pattern; do echo "$item"; done | bl64_vcs_run_git sparse-checkout add --stdin
      } &&
      bl64_vcs_run_git remote add origin "$source" &&
      bl64_vcs_run_git pull --depth 1 origin "$branch"
  fi
  status=$?

  return $status
}

#######################################
# GitHub / Call API
#
# * Call GitHub APIs
# * API calls are executed using Curl wrapper
#
# Arguments:
#   $1: API path. Format: Full path (/X/Y/Z)
#   $2: RESTful method. Format: $BL64_API_METHOD_*. Default: $BL64_API_METHOD_GET
#   $3: API query to be appended to the API path. Format: url encoded string. Default: none
#   $4: API Token. Default: none
#   $5: API Version. Default: $BL64_VCS_GITHUB_API_VERSION
#   $@: additional arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   0: API call executed. Warning: curl exit status only, not the HTTP status code
#   >: unable to execute API call
#######################################
function bl64_vcs_github_run_api() {
  bl64_dbg_lib_show_function "$@"
  local api_path="$1"
  local api_method="${2:-${BL64_API_METHOD_GET}}"
  local api_query="${3:-${BL64_VAR_NULL}}"
  local api_token="${4:-${BL64_VAR_NULL}}"
  local api_version="${5:-${BL64_VCS_GITHUB_API_VERSION}}"

  bl64_check_parameter 'api_path' ||
    return $?

  [[ "$api_token" == "$BL64_VAR_NULL" ]] && api_token=''
  shift
  shift
  shift
  shift
  shift

  # shellcheck disable=SC2086
  bl64_api_call \
    "$BL64_VCS_GITHUB_API_URL" \
    "$api_path" \
    "$api_method" \
    "$api_query" \
    $BL64_RXTX_SET_CURL_HEADER 'Accept: application/vnd.github+json' \
    $BL64_RXTX_SET_CURL_HEADER "X-GitHub-Api-Version: ${api_version}" \
    ${api_token:+${BL64_RXTX_SET_CURL_HEADER} "Authorization: Bearer ${api_token}"} \
    "$@"
}

#######################################
# GitHub / Get release number from latest release
#
# * Uses GitHub API
# * Assumes repo uses standard github release process which binds the latest release to a tag name representing the last version
# * Looks for pattern in json output: "tag_name": "xxxxx"
#
# Arguments:
#   $1: repo owner
#   $2: repo name
# Outputs:
#   STDOUT: release tag
#   STDERR: api error
# Returns:
#   0: api call success
#   >0: api call error
#######################################
function bl64_vcs_github_release_get_latest() {
  bl64_dbg_lib_show_function "$@"
  local repo_owner="$1"
  local repo_name="$2"
  local repo_tag=''

  bl64_check_module 'BL64_VCS_MODULE' &&
    bl64_check_parameter 'repo_owner' &&
    bl64_check_parameter 'repo_name' ||
    return $?

  repo_tag="$(_bl64_vcs_github_release_get_latest "$repo_owner" "$repo_name")" ||
    return $?

  if [[ -n "$repo_tag" ]]; then
    echo "$repo_tag"
  else
    bl64_msg_show_error "$_BL64_VCS_TXT_GET_LATEST_RELEASE_FAILED"
    return $BL64_LIB_ERROR_TASK_FAILED
  fi
}

function _bl64_vcs_github_release_get_latest() {
  bl64_dbg_lib_show_function "$@"
  local repo_owner="$1"
  local repo_name="$2"
  local repo_api_query="/repos/${repo_owner}/${repo_name}/releases/latest"

  # shellcheck disable=SC2086
  bl64_vcs_github_run_api "$repo_api_query" |
    bl64_txt_run_awk \
      ${BL64_TXT_SET_AWS_FS} ':' \
      '/"tag_name": "/ {
        gsub(/[ ",]/,"", $2); print $2
      }'
}
