setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_fs_rm_tmpdir_01: parameters are not present" {
  run bl64_fs_rm_tmpdir
  assert_failure
}