#######################################
# BashLib64 / Module / Functions / Transfer and Receive data over the network
#######################################

#######################################
# Pull data from web server
#
# * If the destination is already present no update is done unless $3=$BL64_VAR_ON
#
# Arguments:
#   $1: Source URL
#   $2: Full path to the destination file
#   $3: replace existing content Values: $BL64_VAR_ON | $BL64_VAR_OFF (default)
#   $4: permissions. Regular chown format accepted. Default: umask defined
# Outputs:
#   STDOUT: None unless BL64_DBG_TARGET_LIB_CMD
#   STDERR: command error
# Returns:
#   BL64_LIB_ERROR_APP_MISSING
#   command error status
#######################################
function bl64_rxtx_web_get_file() {
  bl64_dbg_lib_show_function "$@"
  local source="$1"
  local destination="$2"
  local replace="${3:-${BL64_VAR_DEFAULT}}"
  local mode="${4:-${BL64_VAR_DEFAULT}}"
  local -i status=0

  bl64_check_module 'BL64_RXTX_MODULE' &&
    bl64_check_parameter 'source' &&
    bl64_check_parameter 'destination' || return $?

  bl64_check_overwrite_skip "$destination" "$replace" && return

  bl64_fs_safeguard "$destination" >/dev/null || return $?

  bl64_msg_show_lib_subtask "$_BL64_RXTX_TXT_DOWNLOAD_FILE ($source)"
  # shellcheck disable=SC2086
  if [[ -x "$BL64_RXTX_CMD_CURL" ]]; then
    bl64_rxtx_run_curl \
      $BL64_RXTX_SET_CURL_REDIRECT \
      $BL64_RXTX_SET_CURL_OUTPUT "$destination" \
      "$source"
    status=$?
  elif [[ -x "$BL64_RXTX_CMD_WGET" ]]; then
    bl64_rxtx_run_wget \
      $BL64_RXTX_SET_WGET_OUTPUT "$destination" \
      "$source"
    status=$?
  else
    bl64_msg_show_error "$_BL64_RXTX_TXT_MISSING_COMMAND (wget or curl)" &&
      return $BL64_LIB_ERROR_APP_MISSING
  fi

  # Determine if mode needs to be set
  if [[ "$status" == '0' && "$mode" != "$BL64_VAR_DEFAULT" ]]; then
    bl64_fs_run_chmod "$mode" "$destination"
    status=$?
  fi

  bl64_fs_restore "$destination" "$status" || return $?

  return $status
}

#######################################
# Pull directory contents from git repo
#
# * Content of source path is downloaded into destination (source_path/* --> destionation/). Source path itself is not created
# * If the destination is already present no update is done unless $4=$BL64_VAR_ON
# * If asked to replace destination, temporary backup is done in case git fails by moving the destination to a temp name
# * Warning: git repo info is removed after pull (.git)
#
# Arguments:
#   $1: URL to the GIT repository
#   $2: source path. Format: relative to the repo URL. Use '.' to download the full repo
#   $3: destination path. Format: full path
#   $4: replace existing content. Values: $BL64_VAR_ON | $BL64_VAR_OFF (default)
#   $5: branch name. Default: main
# Outputs:
#   STDOUT: command stdout
#   STDERR: command error
# Returns:
#   0: operation OK
#   BL64_LIB_ERROR_TASK_TEMP
#   command error status
#######################################
function bl64_rxtx_git_get_dir() {
  bl64_dbg_lib_show_function "$@"
  local source_url="${1}"
  local source_path="${2}"
  local destination="${3}"
  local replace="${4:-${BL64_VAR_DEFAULT}}"
  local branch="${5:-main}"
  local -i status=0

  bl64_check_module 'BL64_RXTX_MODULE' &&
    bl64_check_parameter 'source_url' &&
    bl64_check_parameter 'source_path' &&
    bl64_check_parameter 'destination' &&
    bl64_check_path_relative "$source_path" ||
    return $?

  # shellcheck disable=SC2086
  bl64_check_overwrite_skip "$destination" "$replace" && return $?

  # Asked to replace, backup first
  bl64_fs_safeguard "$destination" || return $?

  # Detect what type of path is requested
  if [[ "$source_path" == '.' || "$source_path" == './' ]]; then
    _bl64_rxtx_git_get_dir_root "$source_url" "$destination" "$branch"
  else
    _bl64_rxtx_git_get_dir_sub "$source_url" "$source_path" "$destination" "$branch"
  fi
  status=$?

  # Remove GIT repo metadata
  if [[ -d "${destination}/.git" ]]; then
    bl64_dbg_lib_show_info "remove git metadata (${destination}/.git)"
    # shellcheck disable=SC2164
    cd "$destination"
    bl64_fs_rm_full '.git' >/dev/null
  fi

  # Check if restore is needed
  bl64_fs_restore "$destination" "$status" || return $?
  return $status
}

#######################################
# Command wrapper with verbose, debug and common options
#
# * verbose is not implemented to avoid unintentional alteration of output when using for APIs
#
# Arguments:
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   command exit status
#######################################
function bl64_rxtx_run_curl() {
  bl64_dbg_lib_show_function "$@"
  local debug="$BL64_RXTX_SET_CURL_SILENT"

  bl64_check_parameters_none "$#" &&
    bl64_check_module 'BL64_RXTX_MODULE' &&
    bl64_check_command "$BL64_RXTX_CMD_CURL" || return $?

  bl64_dbg_lib_command_enabled && debug="$BL64_RXTX_SET_CURL_VERBOSE"

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_RXTX_CMD_CURL" \
    $BL64_RXTX_SET_CURL_SECURE \
    $debug \
    "$@"
  bl64_dbg_lib_trace_stop
}

#######################################
# Command wrapper with verbose, debug and common options
#
# Arguments:
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   command exit status
#######################################
function bl64_rxtx_run_wget() {
  bl64_dbg_lib_show_function "$@"
  local verbose=''

  bl64_check_parameters_none "$#" &&
    bl64_check_module 'BL64_RXTX_MODULE' &&
    bl64_check_command "$BL64_RXTX_CMD_WGET" || return $?

  bl64_dbg_lib_command_enabled && verbose="$BL64_RXTX_SET_WGET_VERBOSE"

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_RXTX_CMD_WGET" \
    $verbose \
    "$@"
  bl64_dbg_lib_trace_stop
}

function _bl64_rxtx_git_get_dir_root() {
  bl64_dbg_lib_show_function "$@"
  local source_url="${1}"
  local destination="${2}"
  local branch="${3:-main}"
  local -i status=0
  local repo=''
  local git_name=''
  local transition=''

  bl64_check_module 'BL64_RXTX_MODULE' || return $?

  repo="$($BL64_FS_ALIAS_MKTEMP_DIR)"
  bl64_check_directory "$repo" "$_BL64_RXTX_TXT_CREATION_PROBLEM" || return $BL64_LIB_ERROR_TASK_TEMP

  git_name="$(bl64_fmt_basename "$source_url")"
  git_name="${git_name/.git/}"
  transition="${repo}/${git_name}"
  bl64_dbg_lib_show_vars 'git_name' 'transition'

  # Clone the repo
  bl64_vcs_git_clone "$source_url" "$repo" "$branch" &&
    bl64_dbg_lib_show_info 'promote to destination' &&
    bl64_fs_run_mv "$transition" "$destination"
  status=$?

  [[ -d "$repo" ]] && bl64_fs_rm_full "$repo" >/dev/null
  return $status
}

function _bl64_rxtx_git_get_dir_sub() {
  bl64_dbg_lib_show_function "$@"
  local source_url="${1}"
  local source_path="${2}"
  local destination="${3}"
  local branch="${4:-main}"
  local -i status=0
  local repo=''
  local target=''
  local source=''
  local transition=''

  bl64_check_module 'BL64_RXTX_MODULE' || return $?

  repo="$($BL64_FS_ALIAS_MKTEMP_DIR)"
  # shellcheck disable=SC2086
  bl64_check_directory "$repo" "$_BL64_RXTX_TXT_CREATION_PROBLEM" || return $BL64_LIB_ERROR_TASK_TEMP

  # Use transition path to get to the final target path
  source="${repo}/${source_path}"
  target="$(bl64_fmt_basename "$destination")"
  transition="${repo}/transition/${target}"
  bl64_dbg_lib_show_vars 'source' 'target' 'transition'

  bl64_vcs_git_sparse "$source_url" "$repo" "$branch" "$source_path" &&
    [[ -d "$source" ]] &&
    bl64_fs_mkdir_full "${repo}/transition" &&
    bl64_fs_run_mv "$source" "$transition" >/dev/null &&
    bl64_fs_run_mv "${transition}" "$destination" >/dev/null
  status=$?

  [[ -d "$repo" ]] && bl64_fs_rm_full "$repo" >/dev/null
  return $status
}

#######################################
# Download file asset from release in github repository
#
# Arguments:
#   $1: repo owner
#   $2: repo name
#   $3: release tag. Use $BL64_VCS_GITHUB_LATEST (latest) to obtain latest version
#   $4: asset name: file name available in the target release
#   $5: destination
#   $6: replace existing content Values: $BL64_VAR_ON | $BL64_VAR_OFF (default)
#   $7: permissions. Regular chown format accepted. Default: umask defined
# Outputs:
#   STDOUT: none
#   STDERR: task error
# Returns:
#   0: success
#   >0: error
#######################################
function bl64_rxtx_github_get_asset() {
  bl64_dbg_lib_show_function "$@"
  local repo_owner="$1"
  local repo_name="$2"
  local release_tag="$3"
  local asset_name="$4"
  local destination="$5"
  local replace="${6:-${BL64_VAR_OFF}}"
  local mode="${7:-${BL64_VAR_DEFAULT}}"
  local -i status=0

  bl64_check_module 'BL64_RXTX_MODULE' &&
    bl64_check_parameter 'repo_owner' &&
    bl64_check_parameter 'repo_name' &&
    bl64_check_parameter 'release_tag' &&
    bl64_check_parameter 'asset_name' &&
    bl64_check_parameter 'destination' ||
    return $?

  if [[ "$release_tag" == "$BL64_VCS_GITHUB_LATEST" ]]; then
    release_tag="$(bl64_vcs_github_release_get_latest "$repo_owner" "$repo_name")" ||
      return $?
  fi

  bl64_rxtx_web_get_file \
    "${BL64_RXTX_GITHUB_URL}/${repo_owner}/${repo_name}/releases/download/${release_tag}/${asset_name}" \
    "$destination" "$replace" "$mode"
}
