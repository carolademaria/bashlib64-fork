#######################################
# BashLib64 / Module / Setup / Manage native OS packages
#
# Version: 1.5.1
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
function bl64_pkg_setup() {
  bl64_dbg_lib_show_function

  # shellcheck disable=SC2249
  bl64_pkg_set_command &&
    bl64_pkg_set_paths &&
    bl64_pkg_set_alias &&
    bl64_pkg_set_options &&
    case "$BL64_OS_DISTRO" in
    ${BL64_OS_FD}-*) bl64_check_command "$BL64_PKG_CMD_DNF" ;;
    ${BL64_OS_CNT}-8.* | ${BL64_OS_OL}-8.* | ${BL64_OS_RHEL}-8.* | ${BL64_OS_ALM}-8.* | ${BL64_OS_RCK}-8.*) bl64_check_command "$BL64_PKG_CMD_DNF" ;;
    ${BL64_OS_CNT}-9.* | ${BL64_OS_OL}-9.* | ${BL64_OS_RHEL}-9.*) bl64_check_command "$BL64_PKG_CMD_DNF" ;;
    ${BL64_OS_CNT}-7.* | ${BL64_OS_OL}-7.*) bl64_check_command "$BL64_PKG_CMD_YUM" ;;
    ${BL64_OS_UB}-* | ${BL64_OS_DEB}-*) bl64_check_command "$BL64_PKG_CMD_APT" ;;
    ${BL64_OS_ALP}-*) bl64_check_command "$BL64_PKG_CMD_APK" ;;
    ${BL64_OS_MCOS}-*) bl64_check_command "$BL64_PKG_CMD_BRW" ;;
    esac &&
    BL64_PKG_MODULE="$BL64_VAR_ON"

  bl64_check_alert_module_setup 'pkg'
}

#######################################
# Identify and normalize commands
#
# * Commands are exported as variables with full path
# * The caller function is responsible for checking that the target command is present (installed)
# * Warning: bootstrap function
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function bl64_pkg_set_command() {
  bl64_dbg_lib_show_function
  case "$BL64_OS_DISTRO" in
  ${BL64_OS_FD}-*)
    BL64_PKG_CMD_DNF='/usr/bin/dnf'
    ;;
  ${BL64_OS_CNT}-8.* | ${BL64_OS_OL}-8.* | ${BL64_OS_RHEL}-8.* | ${BL64_OS_ALM}-8.* | ${BL64_OS_RCK}-8.*)
    BL64_PKG_CMD_DNF='/usr/bin/dnf'
    ;;
  ${BL64_OS_CNT}-9.* | ${BL64_OS_OL}-9.* | ${BL64_OS_RHEL}-9.*)
    BL64_PKG_CMD_DNF='/usr/bin/dnf'
    ;;
  ${BL64_OS_CNT}-7.* | ${BL64_OS_OL}-7.*)
    BL64_PKG_CMD_YUM='/usr/bin/yum'
    ;;
  ${BL64_OS_UB}-* | ${BL64_OS_DEB}-*)
    BL64_PKG_CMD_APT='/usr/bin/apt-get'
    ;;
  ${BL64_OS_ALP}-*)
    BL64_PKG_CMD_APK='/sbin/apk'
    ;;
  ${BL64_OS_MCOS}-*)
    BL64_PKG_CMD_BRW='/opt/homebrew/bin/brew'
    ;;
  *) bl64_check_alert_unsupported ;;
  esac
}

#######################################
# Create command sets for common options
#
# * Warning: bootstrap function
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function bl64_pkg_set_options() {
  bl64_dbg_lib_show_function
  # shellcheck disable=SC2034
  case "$BL64_OS_DISTRO" in
  ${BL64_OS_FD}-*)
    BL64_PKG_SET_ASSUME_YES='--assumeyes'
    BL64_PKG_SET_SLIM='--nodocs'
    BL64_PKG_SET_QUIET='--quiet'
    BL64_PKG_SET_VERBOSE='--color=never --verbose'
    ;;
  ${BL64_OS_CNT}-8.* | ${BL64_OS_OL}-8.* | ${BL64_OS_RHEL}-8.* | ${BL64_OS_ALM}-8.* | ${BL64_OS_RCK}-8.*)
    BL64_PKG_SET_ASSUME_YES='--assumeyes'
    BL64_PKG_SET_SLIM='--nodocs'
    BL64_PKG_SET_QUIET='--quiet'
    BL64_PKG_SET_VERBOSE='--color=never --verbose'
    ;;
  ${BL64_OS_CNT}-9.* | ${BL64_OS_OL}-9.* | ${BL64_OS_RHEL}-9.*)
    BL64_PKG_SET_ASSUME_YES='--assumeyes'
    BL64_PKG_SET_SLIM='--nodocs'
    BL64_PKG_SET_QUIET='--quiet'
    BL64_PKG_SET_VERBOSE='--color=never --verbose'
    ;;
  ${BL64_OS_CNT}-7.* | ${BL64_OS_OL}-7.*)
    BL64_PKG_SET_ASSUME_YES='--assumeyes'
    BL64_PKG_SET_SLIM=' '
    BL64_PKG_SET_QUIET='--quiet'
    BL64_PKG_SET_VERBOSE='--color=never --verbose'
    ;;
  ${BL64_OS_UB}-* | ${BL64_OS_DEB}-*)
    BL64_PKG_SET_ASSUME_YES='--assume-yes'
    BL64_PKG_SET_SLIM=' '
    BL64_PKG_SET_QUIET='--quiet --quiet'
    BL64_PKG_SET_VERBOSE='--show-progress'
    ;;
  ${BL64_OS_ALP}-*)
    BL64_PKG_SET_ASSUME_YES=' '
    BL64_PKG_SET_SLIM=' '
    BL64_PKG_SET_QUIET='--quiet'
    BL64_PKG_SET_VERBOSE='--verbose'
    ;;
  ${BL64_OS_MCOS}-*)
    BL64_PKG_SET_ASSUME_YES=' '
    BL64_PKG_SET_SLIM=' '
    BL64_PKG_SET_QUIET='--quiet'
    BL64_PKG_SET_VERBOSE='--verbose'
    ;;
  *) bl64_check_alert_unsupported ;;
  esac
}

#######################################
# Create command aliases for common use cases
#
# * Aliases are presented as regular shell variables for easy inclusion in complex commands
# * Use the alias without quotes, otherwise the shell will interprete spaces as part of the command
# * Warning: bootstrap function
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function bl64_pkg_set_alias() {
  bl64_dbg_lib_show_function
  # shellcheck disable=SC2034
  case "$BL64_OS_DISTRO" in
  ${BL64_OS_FD}-*)
    BL64_PKG_ALIAS_DNF_CACHE="$BL64_PKG_CMD_DNF ${BL64_PKG_SET_VERBOSE} makecache"
    BL64_PKG_ALIAS_DNF_INSTALL="$BL64_PKG_CMD_DNF ${BL64_PKG_SET_VERBOSE} ${BL64_PKG_SET_SLIM} ${BL64_PKG_SET_ASSUME_YES} install"
    BL64_PKG_ALIAS_DNF_CLEAN="$BL64_PKG_CMD_DNF clean all"
    ;;
  ${BL64_OS_CNT}-8.* | ${BL64_OS_OL}-8.* | ${BL64_OS_RHEL}-8.* | ${BL64_OS_ALM}-8.* | ${BL64_OS_RCK}-8.*)
    BL64_PKG_ALIAS_DNF_CACHE="$BL64_PKG_CMD_DNF ${BL64_PKG_SET_VERBOSE} makecache"
    BL64_PKG_ALIAS_DNF_INSTALL="$BL64_PKG_CMD_DNF ${BL64_PKG_SET_VERBOSE} ${BL64_PKG_SET_SLIM} ${BL64_PKG_SET_ASSUME_YES} install"
    BL64_PKG_ALIAS_DNF_CLEAN="$BL64_PKG_CMD_DNF clean all"
    ;;
  ${BL64_OS_CNT}-9.* | ${BL64_OS_OL}-9.* | ${BL64_OS_RHEL}-9.*)
    BL64_PKG_ALIAS_DNF_CACHE="$BL64_PKG_CMD_DNF ${BL64_PKG_SET_VERBOSE} makecache"
    BL64_PKG_ALIAS_DNF_INSTALL="$BL64_PKG_CMD_DNF ${BL64_PKG_SET_VERBOSE} ${BL64_PKG_SET_SLIM} ${BL64_PKG_SET_ASSUME_YES} install"
    BL64_PKG_ALIAS_DNF_CLEAN="$BL64_PKG_CMD_DNF clean all"
    ;;
  ${BL64_OS_CNT}-7.* | ${BL64_OS_OL}-7.*)
    BL64_PKG_ALIAS_YUM_CACHE="$BL64_PKG_CMD_YUM ${BL64_PKG_SET_VERBOSE} makecache"
    BL64_PKG_ALIAS_YUM_INSTALL="$BL64_PKG_CMD_YUM ${BL64_PKG_SET_VERBOSE} ${BL64_PKG_SET_ASSUME_YES} install"
    BL64_PKG_ALIAS_YUM_CLEAN="$BL64_PKG_CMD_YUM clean all"
    ;;
  ${BL64_OS_UB}-* | ${BL64_OS_DEB}-*)
    BL64_PKG_ALIAS_APT_CACHE="$BL64_PKG_CMD_APT update ${BL64_PKG_SET_VERBOSE}"
    BL64_PKG_ALIAS_APT_INSTALL="$BL64_PKG_CMD_APT install ${BL64_PKG_SET_ASSUME_YES} ${BL64_PKG_SET_VERBOSE}"
    BL64_PKG_ALIAS_APT_CLEAN="$BL64_PKG_CMD_APT clean"
    ;;
  ${BL64_OS_ALP}-*)
    BL64_PKG_ALIAS_APK_CACHE="$BL64_PKG_CMD_APK update ${BL64_PKG_SET_VERBOSE}"
    BL64_PKG_ALIAS_APK_INSTALL="$BL64_PKG_CMD_APK add ${BL64_PKG_SET_VERBOSE}"
    BL64_PKG_ALIAS_APK_CLEAN="$BL64_PKG_CMD_APK cache clean ${BL64_PKG_SET_VERBOSE}"
    ;;
  ${BL64_OS_MCOS}-*)
    BL64_PKG_ALIAS_BRW_CACHE="$BL64_PKG_CMD_BRW update ${BL64_PKG_SET_VERBOSE}"
    BL64_PKG_ALIAS_BRW_INSTALL="$BL64_PKG_CMD_BRW install ${BL64_PKG_SET_VERBOSE}"
    BL64_PKG_ALIAS_BRW_CLEAN="$BL64_PKG_CMD_BRW cleanup ${BL64_PKG_SET_VERBOSE} --prune=all -s"
    ;;
  *) bl64_check_alert_unsupported ;;
  esac
}

#######################################
# Set and prepare module paths
#
# * Global paths only
# * If preparation fails the whole module fails
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: check errors
# Returns:
#   0: paths prepared ok
#   >0: failed to prepare paths
#######################################
# shellcheck disable=SC2120
function bl64_pkg_set_paths() {
  bl64_dbg_lib_show_function

  case "$BL64_OS_DISTRO" in
  ${BL64_OS_FD}-*)
    BL64_PKG_PATH_YUM_REPOS_D='/etc/yum.repos.d/'
    ;;
  ${BL64_OS_CNT}-8.* | ${BL64_OS_OL}-8.* | ${BL64_OS_RHEL}-8.* | ${BL64_OS_ALM}-8.* | ${BL64_OS_RCK}-8.*)
    BL64_PKG_PATH_YUM_REPOS_D='/etc/yum.repos.d/'
    ;;
  ${BL64_OS_CNT}-9.* | ${BL64_OS_OL}-9.* | ${BL64_OS_RHEL}-9.*)
    BL64_PKG_PATH_YUM_REPOS_D='/etc/yum.repos.d/'
    ;;
  ${BL64_OS_CNT}-7.* | ${BL64_OS_OL}-7.*)
    BL64_PKG_PATH_YUM_REPOS_D='/etc/yum.repos.d/'
    ;;
  ${BL64_OS_UB}-* | ${BL64_OS_DEB}-*)
    :
    ;;
  ${BL64_OS_ALP}-*)
    :
    ;;
  ${BL64_OS_MCOS}-*)
    :
    ;;
  *) bl64_check_alert_unsupported ;;
  esac

  return 0
}
