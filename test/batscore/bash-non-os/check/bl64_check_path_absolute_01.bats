setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_check_path_absolute: parameter is not present" {

  run bl64_check_path_absolute
  assert_failure

}

