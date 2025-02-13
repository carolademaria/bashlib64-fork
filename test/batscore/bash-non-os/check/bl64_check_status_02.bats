setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_check_status: command true" {
  run "$BL64_OS_CMD_TRUE" && bl64_check_status $? "test ok"
  assert_success
}

@test "bl64_check_status: command false" {
  run "$BL64_OS_CMD_FALSE" && bl64_check_status $? "this command should be considered failed"
  assert_failure
}
