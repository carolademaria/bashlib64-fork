setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_fs_run_cp: parameters are not present" {
  run bl64_fs_run_cp
  assert_failure
}