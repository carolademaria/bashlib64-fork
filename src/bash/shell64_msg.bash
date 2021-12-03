#!/bin/bash
#######################################
# Bash library / Shell64 / Display messages
#
# Author: serdigital64 (https://github.com/serdigital64)
# License: GPL-3.0-or-later (https://www.gnu.org/licenses/gpl-3.0.txt)
# Repository: https://github.com/serdigital64/shell64
# Version: 1.0.0
#######################################

#
# Exported Constants
#

#
# Exported Variables
#

#
# Internal Variables
#

readonly _SHELL64_MSG_TXT_USAGE='Usage'
readonly _SHELL64_MSG_TXT_COMMANDS='Commands'
readonly _SHELL64_MSG_TXT_FLAGS='Flags'
readonly _SHELL64_MSG_TXT_PARAMETERS='Parameters'
readonly _SHELL64_MSG_TXT_ERROR='Error'
readonly _SHELL64_MSG_TXT_INFO='Info'
readonly _SHELL64_MSG_TXT_TASK='Task'
readonly _SHELL64_MSG_TXT_DEBUG='Debug'
readonly _SHELL64_MSG_TXT_WARNING='Warning'

readonly _SHELL64_MSG_HEADER='%s@%s[%(%d/%b/%Y-%H:%M:%S)T]'

#
# Internal Functions
#

#
# Exported Functions
#

#######################################
# Show script usage information
#
# Globals:
#   SHELL64_SCRIPT_NAME
#   SHELL64_LIB_VAR_TBD
#   SHELL64_LIB_VAR_NULL
#   _SHELL64_MSG_TXT_USAGE
#   _SHELL64_MSG_TXT_COMMANDS
#   _SHELL64_MSG_TXT_FLAGS
#   _SHELL64_MSG_TXT_PARAMETERS
#   _SHELL64_MSG_TXT_USAGE
# Arguments:
#   $1: script command line. Include all required and optional components
#   $2: full script usage description
#   $3: list of script commands
#   $4: list of script flags
#   $5: list of script parameters
# Outputs:
#   STDOUT: usage info
#   STDERR: None
# Returns:
#   0: successfull execution
#   >0: failed to execute due to formatting errors
#######################################
function shell64_msg_show_usage() {

  local usage="${1:-$SHELL64_LIB_VAR_TBD}"
  local description="${2:-$SHELL64_LIB_VAR_NULL}"
  local commands="${3:-$SHELL64_LIB_VAR_NULL}"
  local flags="${4:-$SHELL64_LIB_VAR_NULL}"
  local parameters="${5:-$SHELL64_LIB_VAR_NULL}"

  printf '\n%s: %s %s\n\n' "$_SHELL64_MSG_TXT_USAGE" "$SHELL64_SCRIPT_NAME" "$usage"

  if [[ "$description" != "$SHELL64_LIB_VAR_NULL" ]]; then
    printf '%s\n\n' "$description"
  fi

  if [[ "$commands" != "$SHELL64_LIB_VAR_NULL" ]]; then
    printf '%s\n%s\n' "$_SHELL64_MSG_TXT_COMMANDS" "$commands"
  fi

  if [[ "$flags" != "$SHELL64_LIB_VAR_NULL" ]]; then
    printf '%s\n%s\n' "$_SHELL64_MSG_TXT_FLAGS" "$flags"
  fi

  if [[ "$parameters" != "$SHELL64_LIB_VAR_NULL" ]]; then
    printf '%s\n%s\n' "$_SHELL64_MSG_TXT_PARAMETERS" "$parameters"
  fi

  return 0

}

#######################################
# Display error message
#
# Globals:
#   SHELL64_LIB_VAR_TBD
#   SHELL64_SCRIPT_NAME
#   _SHELL64_MSG_HEADER
#   _SHELL64_MSG_TXT_ERROR
# Arguments:
#   $1: error message
# Outputs:
#   STDOUT: none
#   STDERR: message
# Returns:
#   0: successfull execution
#   >0: failed to execute due to formatting errors
#######################################
function shell64_msg_show_error() {

  local message="${1-$SHELL64_LIB_VAR_TBD}"

  printf "$_SHELL64_MSG_HEADER %s: %s\n" \
    "$SHELL64_SCRIPT_NAME" \
    "$HOSTNAME" \
    '-1' \
    "$_SHELL64_MSG_TXT_ERROR" \
    "$message" >&2

  return 0

}

#######################################
# Display warning message
#
# Globals:
#   SHELL64_LIB_VAR_TBD
#   SHELL64_SCRIPT_NAME
#   _SHELL64_MSG_HEADER
#   _SHELL64_MSG_TXT_WARNING
# Arguments:
#   $1: warning message
# Outputs:
#   STDOUT: none
#   STDERR: message
# Returns:
#   0: successfull execution
#   >0: failed to execute due to formatting errors
#######################################
function shell64_msg_show_warning() {

  local message="${1-$SHELL64_LIB_VAR_TBD}"

  printf "$_SHELL64_MSG_HEADER %s: %s\n" \
    "$SHELL64_SCRIPT_NAME" \
    "$HOSTNAME" \
    '-1' \
    "$_SHELL64_MSG_TXT_WARNING" \
    "$message" >&2

  return 0

}

#######################################
# Display info message
#
# Globals:
#   SHELL64_LIB_VAR_TBD
#   SHELL64_SCRIPT_NAME
#   _SHELL64_MSG_HEADER
#   _SHELL64_MSG_TXT_INFO
# Arguments:
#   $1: message
# Outputs:
#   STDOUT: message
#   STDERR: None
# Returns:
#   0: successfull execution
#   >0: failed to execute due to formatting errors
#######################################
function shell64_msg_show_info() {

  local message="${1-$SHELL64_LIB_VAR_TBD}"

  printf "$_SHELL64_MSG_HEADER %s: %s\n" \
    "$SHELL64_SCRIPT_NAME" \
    "$HOSTNAME" \
    '-1' \
    "$_SHELL64_MSG_TXT_INFO" \
    "$message"

  return 0

}

#######################################
# Display task message
#
# Globals:
#   SHELL64_LIB_VAR_TBD
#   SHELL64_SCRIPT_NAME
#   _SHELL64_MSG_HEADER
#   _SHELL64_MSG_TXT_TASK
# Arguments:
#   $1: message
# Outputs:
#   STDOUT: message
#   STDERR: None
# Returns:
#   0: successfull execution
#   >0: failed to execute due to formatting errors
#######################################
function shell64_msg_show_task() {

  local message="${1-$SHELL64_LIB_VAR_TBD}"

  printf "$_SHELL64_MSG_HEADER %s: %s\n" \
    "$SHELL64_SCRIPT_NAME" \
    "$HOSTNAME" \
    '-1' \
    "$_SHELL64_MSG_TXT_TASK" \
    "$message"

  return 0

}

#######################################
# Display debug message
#
# Globals:
#   SHELL64_LIB_VAR_TBD
#   SHELL64_SCRIPT_NAME
#   _SHELL64_MSG_HEADER
#   _SHELL64_MSG_TXT_DEBUG
# Arguments:
#   $1: message
# Outputs:
#   STDOUT: None
#   STDERR: message
# Returns:
#   0: successfull execution
#   >0: failed to execute due to formatting errors
#######################################
function shell64_msg_show_debug() {

  local message="${1-$SHELL64_LIB_VAR_TBD}"

  printf "$_SHELL64_MSG_HEADER %s: %s\n" \
    "$SHELL64_SCRIPT_NAME" \
    "$HOSTNAME" \
    '-1' \
    "$_SHELL64_MSG_TXT_DEBUG" \
    "$message" >&2

  return 0

}

#######################################
# Display message
#
# Globals:
#   SHELL64_LIB_VAR_TBD
# Arguments:
#   $1: message
# Outputs:
#   STDOUT: message
#   STDERR: None
# Returns:
#   0: successfull execution
#   >0: failed to execute due to formatting errors
#######################################
function shell64_msg_show_text() {

  local message="${1-$SHELL64_LIB_VAR_TBD}"

  printf '%s\n' "$message"

  return 0

}
