setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  _bl64_rxtx_git_get_dir_destination="$(temp_make)"
  _bl64_rxtx_git_get_dir_source="$DEV_TEST_VALUE_GIT_CLONE_URL"
  export _bl64_rxtx_git_get_dir_destination
  export _bl64_rxtx_git_get_dir_source

}

@test "bl64_rxtx_git_get_dir: parameters are not present" {
  run bl64_rxtx_git_get_dir
  assert_failure
}

@test "bl64_rxtx_git_get_dir: 2nd parameter is not present" {
  run bl64_rxtx_git_get_dir '/dev/null'
  assert_failure
}

@test "bl64_rxtx_git_get_dir: 3th parameter is not present" {
  run bl64_rxtx_git_get_dir '/dev/null'
  assert_failure
}
