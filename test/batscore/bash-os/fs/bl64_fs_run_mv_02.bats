setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"

  TEST_SANDBOX="$(temp_make)"
  TEST_FILE="${TEST_SANDBOX}/test_file"
  TEST_NEW_FILE="${TEST_SANDBOX}/test_new_file"
}

@test "bl64_fs_run_mv: move a file to another dir" {
  touch "${TEST_FILE}"
  run bl64_fs_run_mv "${TEST_FILE}" "$TEST_NEW_FILE"
  assert_success
  assert_file_exist "$TEST_NEW_FILE"
  assert_file_not_exist "$TEST_FILE"
}

teardown() {
  temp_del "$TEST_SANDBOX"
}
