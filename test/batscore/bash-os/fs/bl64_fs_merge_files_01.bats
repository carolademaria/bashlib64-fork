setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_fs_merge_files: no args" {
  run bl64_fs_merge_files
  assert_failure
}

@test "bl64_fs_merge_files: 1 arg" {
  run bl64_fs_merge_files "${BL64_VAR_DEFAULT}"
  assert_failure
}

@test "bl64_fs_merge_files: 2 args" {
  run bl64_fs_merge_files "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}"
  assert_failure
}

@test "bl64_fs_merge_files: 3 args" {
  run bl64_fs_merge_files "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}"
  assert_failure
}

@test "bl64_fs_merge_files: 4 args" {
  run bl64_fs_merge_files "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}"
  assert_failure
}

@test "bl64_fs_merge_files: 5 args" {
  run bl64_fs_merge_files "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}" "${BL64_VAR_DEFAULT}"
  assert_failure
}
