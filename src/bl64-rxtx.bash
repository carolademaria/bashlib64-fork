#######################################
# BashLib64 / Transfer and Receive data over the network
#
# Author: serdigital64 (https://github.com/serdigital64)
# License: GPL-3.0-or-later (https://www.gnu.org/licenses/gpl-3.0.txt)
# Repository: https://github.com/serdigital64/bashlib64
# Version: 1.0.0
#######################################

#######################################
# Identify and normalize commands
#
# * Commands are exported as variables with full path
# * The caller function is responsible for checking that the target command is present (installed)
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function bl64_rxtx_set_command() {
  case "$BL64_OS_DISTRO" in
  UBUNTU-* | DEBIAN-* | FEDORA-* | CENTOS-* | OL-* | ALPINE-*)
    BL64_RXTX_CMD_CURL='/usr/bin/curl'
    BL64_RXTX_CMD_WGET='/usr/bin/wget'
    ;;
  esac
}

#######################################
# Pull data from web server
#
# Arguments:
#   $1: Source URL
#   $2: Full path to the destination file
# Outputs:
#   STDOUT: None unless BL64_LIB_DEBUG_CMD is enabled
#   STDERR: command error
# Returns:
#   BL64_RXTX_ERROR_MISSING_PARAMETER
#   BL64_RXTX_ERROR_MISSING_COMMAND
#   command error status
#######################################
function bl64_rxtx_web_get_file() {
  local source="$1"
  local destination="$2"
  local verbose=''

  if [[ -z "$source" ]]; then
    bl64_msg_show_error "$_BL64_RXTX_TXT_MISSING_PARAMETER (source url)"
    # shellcheck disable=SC2086
    return $BL64_RXTX_ERROR_MISSING_PARAMETER
  fi

  if [[ -z "$destination" ]]; then
    bl64_msg_show_error "$_BL64_RXTX_TXT_MISSING_PARAMETER (source url)"
    # shellcheck disable=SC2086
    return $BL64_RXTX_ERROR_MISSING_PARAMETER
  fi

  if [[ -x "$BL64_RXTX_CMD_CURL" ]]; then
    [[ "$BL64_LIB_DEBUG" == "$BL64_LIB_DEBUG_CMD" ]] && verbose='--verbose'
    "$BL64_RXTX_CMD_CURL" $verbose \
      --no-progress-meter \
      --config '/dev/null' \
      --output "$destination" \
      "$source"
  elif [[ -x "$BL64_RXTX_CMD_WGET" ]]; then
    [[ "$BL64_LIB_DEBUG" == "$BL64_LIB_DEBUG_CMD" ]] && verbose='--verbose'
    "$BL64_RXTX_CMD_WGET" $verbose \
      --no-config \
      --no-directories \
      --output-document "$destination" \
      "$source"
  else
    # shellcheck disable=SC2086
    bl64_msg_show_error "$_BL64_RXTX_TXT_MISSING_COMMAND (wget or curl)" &&
      return $BL64_RXTX_ERROR_MISSING_COMMAND
  fi

}

#######################################
# Pull directory structure from git repo
#
# * git repo info is removed after pull (.git)
#
# Arguments:
#   $1: URL to the GIT repository
#   $2: destination path where the repository will be created
#   $3: branch name. Default: main
#   $4: include pattern list. Field separator: space
# Outputs:
#   STDOUT: command stdout
#   STDERR: command error
# Returns:
#   command error status
#######################################
function bl64_rxtx_git_get_dir() {
  local source="${1}"
  local destination="${2}"
  local branch="${3:-main}"
  local pattern="${4}"
  local git_data="$destination/.git"
  local status=0

  bl64_vcs_git_sparse "$source" "$destination" "$branch" "$pattern"
  status=$?

  [[ -d "$git_data" ]] && bl64_os_rm_full "$git_data"
  return $status
}
