setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  bl64_arc_setup
}

@test "bl64_arc_blank_unzip: run ok" {
  run bl64_arc_blank_unzip
  assert_success
}

