setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_fs_set_permissions: no args" {
  run bl64_fs_set_permissions
  assert_failure
}

@test "bl64_fs_set_permissions: no path" {
  run bl64_fs_set_permissions "$BL64_VAR_DEFAULT" "$BL64_VAR_DEFAULT" "$BL64_VAR_DEFAULT"
  assert_failure
}