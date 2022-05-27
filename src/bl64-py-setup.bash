#######################################
# BashLib64 / Module / Setup / Interact with system-wide Python
#
# Version: 1.3.0
#######################################

#######################################
# Setup the bashlib64 module
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: setup ok
#   >0: setup failed
#######################################
function bl64_py_setup() {
  bl64_dbg_lib_show_function

  bl64_py_set_command &&
    bl64_py_set_options &&
    bl64_check_command "$BL64_PY_CMD_PYTHON3" &&
    BL64_PY_MODULE="$BL64_LIB_VAR_ON"
}

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
function bl64_py_set_command() {
  bl64_dbg_lib_show_function

  # Define distro native Python versions
  # shellcheck disable=SC2034
  case "$BL64_OS_DISTRO" in
  ${BL64_OS_CNT}-7.* | ${BL64_OS_OL}-7.*) BL64_PY_CMD_PYTHON36='/usr/bin/python3' ;;
  ${BL64_OS_CNT}-8.* | ${BL64_OS_OL}-8.* | ${BL64_OS_RHEL}-* | ${BL64_OS_ALM}-* | ${BL64_OS_RCK}-*)
    BL64_PY_CMD_PYTHON36='/usr/bin/python3'
    BL64_PY_CMD_PYTHON39='/usr/bin/python3.9'
    ;;
  ${BL64_OS_CNT}-9.*) BL64_PY_CMD_PYTHON39='/usr/bin/python3.9' ;;
  ${BL64_OS_FD}-33.* | ${BL64_OS_FD}-34.*) BL64_PY_CMD_PYTHON39='/usr/bin/python3.9' ;;
  ${BL64_OS_FD}-35.*) BL64_PY_CMD_PYTHON310='/usr/bin/python3.10' ;;
  ${BL64_OS_DEB}-9.*) BL64_PY_CMD_PYTHON35='/usr/bin/python3.5' ;;
  ${BL64_OS_DEB}-10.*) BL64_PY_CMD_PYTHON37='/usr/bin/python3.7' ;;
  ${BL64_OS_DEB}-11.*) BL64_PY_CMD_PYTHON39='/usr/bin/python3.9' ;;
  ${BL64_OS_UB}-20.*) BL64_PY_CMD_PYTHON38='/usr/bin/python3.8' ;;
  ${BL64_OS_UB}-21.*) BL64_PY_CMD_PYTHON39='/usr/bin/python3.9' ;;
  ${BL64_OS_UB}-22.*) BL64_PY_CMD_PYTHON310='/usr/bin/python3.10' ;;
  ${BL64_OS_ALP}-3.*) BL64_PY_CMD_PYTHON39='/usr/bin/python3.9' ;;
  ${BL64_OS_MCOS}-12.*) BL64_PY_CMD_PYTHON39='/usr/bin/python3.9' ;;
  *) bl64_check_alert_unsupported ;;
  esac

  # Select best match for default python3
  if [[ -x "$BL64_PY_CMD_PYTHON310" ]]; then
    BL64_PY_CMD_PYTHON3="$BL64_PY_CMD_PYTHON310"
  elif [[ -x "$BL64_PY_CMD_PYTHON39" ]]; then
    BL64_PY_CMD_PYTHON3="$BL64_PY_CMD_PYTHON39"
  elif [[ -x "$BL64_PY_CMD_PYTHON38" ]]; then
    BL64_PY_CMD_PYTHON3="$BL64_PY_CMD_PYTHON38"
  elif [[ -x "$BL64_PY_CMD_PYTHON37" ]]; then
    BL64_PY_CMD_PYTHON3="$BL64_PY_CMD_PYTHON37"
  elif [[ -x "$BL64_PY_CMD_PYTHON36" ]]; then
    BL64_PY_CMD_PYTHON3="$BL64_PY_CMD_PYTHON36"
  elif [[ -x "$BL64_PY_CMD_PYTHON35" ]]; then
    BL64_PY_CMD_PYTHON3="$BL64_PY_CMD_PYTHON35"
  fi
  bl64_dbg_lib_show_vars 'BL64_PY_CMD_PYTHON3'

}

#######################################
# Create command sets for common options
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function bl64_py_set_options() {
  bl64_dbg_lib_show_function
  # Common sets - unversioned
  BL64_PY_SET_PIP_VERBOSE='--verbose'
  BL64_PY_SET_PIP_DEBUG='-vvv'
  BL64_PY_SET_PIP_VERSION='--version'
  BL64_PY_SET_PIP_UPGRADE='--upgrade'
  BL64_PY_SET_PIP_USER='--user'
  BL64_PY_SET_PIP_QUIET='--quiet'
}
