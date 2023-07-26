setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  _bl64_rxtx_git_get_dir_destination="$(temp_make)"
  _bl64_rxtx_git_get_dir_source="$DEVBL_TEST_VALUE_GIT_CLONE_URL"
  export _bl64_rxtx_git_get_dir_destination
  export _bl64_rxtx_git_get_dir_source

}

@test "bl64_rxtx_run_wget: parameters are not present" {
  run bl64_rxtx_run_wget
  assert_failure
}
