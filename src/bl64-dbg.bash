#######################################
# BashLib64 / Module / Functions / Show shell debugging information
#######################################

function _bl64_dbg_show() {
  local message="$1"
  printf '%s: %s\n' "$_BL64_DBG_TXT_DEBUG" "$message" >&2
}

#######################################
# Show runtime info
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: runtime info
# Returns:
#   latest exit status (before function call)
#######################################
function bl64_dbg_runtime_show() {
  local -i last_status=$?

  if [[ "$BL64_DBG_TARGET" == "$BL64_DBG_TARGET_APP_CMD" ]]; then
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_BASH}: [${BASH}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_BASHOPTS}: [${BASHOPTS:-NONE}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_SHELLOPTS}: [${SHELLOPTS:-NONE}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_BASH_VERSION}: [${BASH_VERSION}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_OSTYPE}: [${OSTYPE:-NONE}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_LC_ALL}: [${LC_ALL:-NONE}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_HOSTNAME}: [${HOSTNAME:-EMPTY}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_EUID}: [${EUID}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_UID}: [${UID}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_BASH_ARGV}: [${BASH_ARGV[*]:-NONE}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_COMMAND}: [${BASH_COMMAND:-NONE}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_STATUS}: [${last_status}]"

    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_SCRIPT_PATH}: [${BL64_SCRIPT_PATH:-EMPTY}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_HOME}: [${HOME:-EMPTY}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_PATH}: [${PATH:-EMPTY}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_CD_PWD}: [${PWD:-EMPTY}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_CD_OLDPWD}: [${OLDPWD:-EMPTY}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_PWD}: [$(pwd)]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_TMPDIR}: [${TMPDIR:-NONE}]"

    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_CALLSTACK}(1): [${BASH_SOURCE[1]:-NONE}:${FUNCNAME[1]:-NONE}:${BASH_LINENO[1]:-0}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_CALLSTACK}(2): [${BASH_SOURCE[2]:-NONE}:${FUNCNAME[2]:-NONE}:${BASH_LINENO[2]:-0}]"
    _bl64_dbg_show "[bash] ${_BL64_DBG_TXT_CALLSTACK}(3): [${BASH_SOURCE[3]:-NONE}:${FUNCNAME[3]:-NONE}:${BASH_LINENO[3]:-0}]"
  fi

  # shellcheck disable=SC2248
  return $last_status
}

#######################################
# Show runtime call stack
#
# * Show previous 3 functions from the current caller
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: callstack
# Returns:
#   latest exit status (before function call)
#######################################
function bl64_dbg_runtime_show_callstack() {
  bl64_dbg_app_task_enabled || bl64_dbg_lib_task_enabled || return 0
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_CALLSTACK}(2): [${BASH_SOURCE[1]:-NONE}:${FUNCNAME[2]:-NONE}:${BASH_LINENO[2]:-0}]"
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_CALLSTACK}(3): [${BASH_SOURCE[2]:-NONE}:${FUNCNAME[3]:-NONE}:${BASH_LINENO[3]:-0}]"
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_CALLSTACK}(4): [${BASH_SOURCE[3]:-NONE}:${FUNCNAME[4]:-NONE}:${BASH_LINENO[4]:-0}]"
}

#######################################
# Show runtime paths
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: callstack
# Returns:
#   latest exit status (before function call)
#######################################
function bl64_dbg_runtime_show_paths() {
  bl64_dbg_app_task_enabled || bl64_dbg_lib_task_enabled || return 0
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_SCRIPT_PATH}: [${BL64_SCRIPT_PATH:-EMPTY}]"
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_HOME}: [${HOME:-EMPTY}]"
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_PATH}: [${PATH:-EMPTY}]"
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_CD_PWD}: [${PWD:-EMPTY}]"
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_CD_OLDPWD}: [${OLDPWD:-EMPTY}]"
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_PWD}: [$(pwd)]"
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_TMPDIR}: [${TMPDIR:-NONE}]"
}

#######################################
# Stop app  shell tracing
#
# * Saves the last exit status so the function will not disrupt the error flow
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function bl64_dbg_app_trace_stop() {
  local -i state=$?
  bl64_dbg_app_trace_enabled || return $state

  set +x
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_FUNCTION_STOP}"

  return $state
}

#######################################
# Start app  shell tracing if target is in scope
#
# Arguments:
#   None
# Outputs:
#   STDOUT: Tracing
#   STDERR: Debug messages
# Returns:
#   0: always ok
#######################################
function bl64_dbg_app_trace_start() {
  bl64_dbg_app_trace_enabled || return 0

  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_FUNCTION_START}"
  set -x

  return 0
}

#######################################
# Stop bashlib64 shell tracing
#
# * Saves the last exit status so the function will not disrupt the error flow
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   Saved exit status
#######################################
function bl64_dbg_lib_trace_stop() {
  local -i state=$?
  bl64_dbg_lib_trace_enabled || return $state

  set +x
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_FUNCTION_STOP}"

  return $state
}

#######################################
# Start bashlib64 shell tracing if target is in scope
#
# Arguments:
#   None
# Outputs:
#   STDOUT: Tracing
#   STDERR: Debug messages
# Returns:
#   0: always ok
#######################################
function bl64_dbg_lib_trace_start() {
  bl64_dbg_lib_trace_enabled || return 0

  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_FUNCTION_START}"
  set -x

  return 0
}

#######################################
# Show bashlib64 task level debugging information
#
# Arguments:
#   $1: message
# Outputs:
#   STDOUT: None
#   STDERR: Debug message
# Returns:
#   0: always ok
#######################################
function bl64_dbg_lib_show_info() {
  bl64_dbg_lib_task_enabled || return 0
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${*}"
  return 0
}

#######################################
# Show app task level debugging information
#
# Arguments:
#   $@: messages
# Outputs:
#   STDOUT: None
#   STDERR: Debug message
# Returns:
#   0: always ok
#######################################
function bl64_dbg_app_show_info() {
  bl64_dbg_app_task_enabled || return 0
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${*}"
  return 0
}

#######################################
# Show bashlib64 task level variable values
#
# Arguments:
#   $@: variable names
# Outputs:
#   STDOUT: None
#   STDERR: Debug message
# Returns:
#   0: always ok
#######################################
function bl64_dbg_lib_show_vars() {
  local variable=''
  bl64_dbg_lib_task_enabled || return 0

  for variable in "$@"; do
    eval "_bl64_dbg_show \"[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_SHELL_VAR}: [${variable}=\$${variable}]\""
  done

  return 0
}

#######################################
# Show app task level variable values
#
# Arguments:
#   $@: variable names
# Outputs:
#   STDOUT: None
#   STDERR: Debug message
# Returns:
#   0: always ok
#######################################
function bl64_dbg_app_show_vars() {
  local variable=''
  bl64_dbg_app_task_enabled || return 0

  for variable in "$@"; do
    eval "_bl64_dbg_show \"[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_SHELL_VAR}: [${variable}=\$${variable}]\""
  done

  return 0
}

#######################################
# Show bashlib64 function name and parameters
#
# Arguments:
#   $@: parameters
# Outputs:
#   STDOUT: None
#   STDERR: Debug message
# Returns:
#   0: always ok
#######################################
# shellcheck disable=SC2120
function bl64_dbg_lib_show_function() {
  bl64_dbg_lib_task_enabled || return 0
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_FUNCTION_LIB_RUN}: [${*}]"
  return 0
}

#######################################
# Show app function name and parameters
#
# Arguments:
#   $@: parameters
# Outputs:
#   STDOUT: None
#   STDERR: Debug message
# Returns:
#   0: always ok
#######################################
# shellcheck disable=SC2120
function bl64_dbg_app_show_function() {
  bl64_dbg_app_task_enabled || return 0
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_FUNCTION_APP_RUN}: [${*}]"
  return 0
}

#######################################
# Stop bashlib64 external command tracing
#
# * Saves the last exit status so the function will not disrupt the error flow
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   Saved exit status
#######################################
function bl64_dbg_lib_command_trace_stop() {
  local -i state=$?
  bl64_dbg_lib_task_enabled || return $state

  set +x
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_FUNCTION_STOP}"

  return $state
}

#######################################
# Start bashlib64 external command tracing if target is in scope
#
# * Use in functions: bl64_*_run_*
#
# Arguments:
#   None
# Outputs:
#   STDOUT: Tracing
#   STDERR: Debug messages
# Returns:
#   0: always ok
#######################################
function bl64_dbg_lib_command_trace_start() {
  bl64_dbg_lib_task_enabled || return 0

  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_FUNCTION_START}"
  set -x

  return 0
}

#######################################
# Show developer comments in bashlib64 functions
#
# Arguments:
#   $1: comments
# Outputs:
#   STDOUT: None
#   STDERR: Debug message
# Returns:
#   0: always ok
#######################################
function bl64_dbg_lib_show_comments() {
  bl64_dbg_lib_task_enabled || return 0
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_COMMENTS}: ${*}"
  return 0
}

#######################################
# Show developer comments in app functions
#
# Arguments:
#   $@: comments
# Outputs:
#   STDOUT: None
#   STDERR: Debug message
# Returns:
#   0: always ok
#######################################
function bl64_dbg_app_show_comments() {
  bl64_dbg_app_task_enabled || return 0
  _bl64_dbg_show "[${FUNCNAME[1]:-NONE}] ${_BL64_DBG_TXT_COMMENTS}: ${*}"
  return 0
}
