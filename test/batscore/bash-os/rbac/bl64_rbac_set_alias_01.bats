setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "_bl64_rbac_set_alias: run function" {
  run _bl64_rbac_set_alias
  assert_success
}