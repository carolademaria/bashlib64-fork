setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  bl64_iam_setup
}

@test "bl64_iam_user_is_created: no args" {
  run bl64_iam_user_is_created
  assert_failure
}
