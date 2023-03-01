#######################################
# BashLib64 / Module / Setup / Generate random data
#
# Version: 1.0.0
#######################################

#######################################
# Setup the bashlib64 module
#
# * Warning: bootstrap function
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
function bl64_rnd_setup() {
  bl64_dbg_lib_show_function

  BL64_RND_MODULE="$BL64_VAR_ON"
}