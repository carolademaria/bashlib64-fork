setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"

}

@test "_bl64_bsh_set_version: commands are set" {

  assert_not_equal "${BL64_BSH_VERSION_BASH}" ''

}
