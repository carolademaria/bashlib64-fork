setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_fs_restore: parameters are not present" {
  run bl64_fs_restore
  assert_failure
}