#######################################
# BashLib64 / Module / Functions / Interact with Kubernetes
#
# Version: 1.1.1
#######################################

#######################################
# Set label on resource
#
# Arguments:
#   $1: full path to the kube/config file for the target cluster
#   $2: resource type
#   $3: resource name
#   $4: label name
#   $5: label value
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   command exit status
#######################################
function bl64_k8s_label_set() {
  bl64_dbg_lib_show_function "$@"
  local kubeconfig="${1:-${BL64_LIB_VAR_NULL}}"
  local resource="${2:-${BL64_LIB_VAR_NULL}}"
  local name="${3:-${BL64_LIB_VAR_NULL}}"
  local key="${4:-${BL64_LIB_VAR_NULL}}"
  local value="${5:-${BL64_LIB_VAR_NULL}}"

  bl64_check_parameter 'resource' &&
    bl64_check_parameter 'name' &&
    bl64_check_parameter 'key' &&
    bl64_check_parameter 'value' ||
    return $?

  bl64_k8s_run_kubectl \
    "$kubeconfig" \
    label \
    --overwrite \
    "$resource" \
    "$name" \
    "$key"="$value"
}

#######################################
# Create namespace
#
# Arguments:
#   $1: full path to the kube/config file for the target cluster
#   $2: namespace name
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   command exit status
#######################################
function bl64_k8s_namespace_create() {
  bl64_dbg_lib_show_function "$@"
  local kubeconfig="${1:-${BL64_LIB_VAR_NULL}}"
  local namespace="${2:-${BL64_LIB_VAR_NULL}}"

  bl64_check_parameter 'namespace' ||
    return $?

  if bl64_k8s_resource_is_created "$kubeconfig" "$BL64_K8S_RESOURCE_NAMESPACE" "$namespace"; then
    bl64_dbg_lib_show_info "requested namespace is already created. No need to take action. (${namespace})"
    return 0
  fi

  bl64_k8s_run_kubectl "$kubeconfig" create namespace "$namespace"
}

#######################################
# Apply updates to resources based on definition file
#
# Arguments:
#   $1: full path to the kube/config file for the target cluster
#   $2: namespace where resources are
#   $3: full path to the resource definition file
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   command exit status
#######################################
function bl64_k8s_resource_update() {
  bl64_dbg_lib_show_function "$@"
  local kubeconfig="${1:-${BL64_LIB_VAR_NULL}}"
  local namespace="${2:-${BL64_LIB_VAR_NULL}}"
  local definition="${3:-${BL64_LIB_VAR_NULL}}"

  bl64_check_parameter 'namespace' &&
    bl64_check_parameter 'definition' &&
    bl64_check_file "$definition" ||
    return $?

  bl64_k8s_run_kubectl \
    "$kubeconfig" \
    --namespace "$namespace" \
    apply \
    --force='false' \
    --force-conflicts='false' \
    --grace-period='-1' \
    --overwrite='true' \
    --validate='strict' \
    --wait='true' \
    --filename="$definition"

}

#######################################
# Command wrapper with verbose, debug and common options
#
# * Trust no one. Ignore inherited config and use explicit
#
# Arguments:
#   $1: full path to the kube/config file for the target cluster
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   command exit status
#######################################
function bl64_k8s_run_kubectl() {
  bl64_dbg_lib_show_function "$@"
  local kubeconfig="${1:-}"
  local verbosity="$BL64_K8S_SET_VERBOSE_NONE"

  bl64_check_parameters_none "$#" &&
    bl64_check_parameter 'kubeconfig' &&
    bl64_check_file "$kubeconfig" &&
    bl64_check_module 'BL64_K8S_MODULE' ||
    return $?

  bl64_msg_lib_verbose_enabled && verbosity="$BL64_K8S_SET_VERBOSE_NORMAL"
  bl64_dbg_lib_command_enabled && verbosity="$BL64_K8S_SET_VERBOSE_TRACE"

  bl64_k8s_blank_kubectl
  shift

  bl64_dbg_lib_command_trace_start
  # shellcheck disable=SC2086
  "$BL64_K8S_CMD_KUBECTL" \
    --kubeconfig="$kubeconfig" \
    $verbosity "$@"
  bl64_dbg_lib_command_trace_stop
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
function bl64_k8s_blank_kubectl() {
  bl64_dbg_lib_show_function

  bl64_dbg_lib_show_info 'unset inherited HELM_* shell variables'
  bl64_dbg_lib_trace_start
  unset POD_NAMESPACE
  unset KUBECONFIG
  bl64_dbg_lib_trace_stop

  return 0
}

#######################################
# Verify that the resource is created
#
# Arguments:
#   $1: full path to the kube/config file for the target cluster
#   $2: resource type
#   $3: resource name
#   $4: namespace where resources are
# Outputs:
#   STDOUT: nothing
#   STDERR: nothing unless debug
# Returns:
#   0: resource exists
#   >0: resources does not exist or execution error
#######################################
function bl64_k8s_resource_is_created() {
  bl64_dbg_lib_show_function "$@"
  local kubeconfig="${1:-${BL64_LIB_VAR_NULL}}"
  local type="${2:-${BL64_LIB_VAR_NULL}}"
  local name="${3:-${BL64_LIB_VAR_NULL}}"
  local namespace="${4:-}"

  bl64_check_parameter 'type' &&
    bl64_check_parameter 'name' ||
    return $?

  [[ -n "$namespace" ]] && namespace="--namespace ${namespace}"

  # shellcheck disable=SC2086
  if bl64_dbg_lib_task_enabled; then
    bl64_k8s_run_kubectl "$kubeconfig" \
      get "$type" "$name" \
      "$BL64_K8S_SET_OUTPUT_NAME" $namespace
  else
    bl64_k8s_run_kubectl "$kubeconfig" \
      get "$type" "$name" \
      "$BL64_K8S_SET_OUTPUT_NAME" $namespace >/dev/null 2>&1
  fi
}
