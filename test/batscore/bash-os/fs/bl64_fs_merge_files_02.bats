setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"

  BATSLIB_TEMP_PRESERVE=0
  BATSLIB_TEMP_PRESERVE_ON_FAILURE=1

  TEST_SANDBOX="$(temp_make)"
}

@test "bl64_fs_merge_files: defaults, merge ok" {

  run bl64_fs_merge_files \
    "$BL64_VAR_DEFAULT" \
    "$BL64_VAR_DEFAULT" \
    "$BL64_VAR_DEFAULT" \
    "$BL64_VAR_DEFAULT" \
    "${TEST_SANDBOX}/merge_result.txt" \
    "${TESTMANSH_TEST_SAMPLES}/merge_files_01/file1.txt" \
    "${TESTMANSH_TEST_SAMPLES}/merge_files_01/file2.txt" \
    "${TESTMANSH_TEST_SAMPLES}/merge_files_01/file3.txt"
  assert_success
  assert_file_exist "${TEST_SANDBOX}/merge_result.txt"
}

teardown() {
  temp_del "$TEST_SANDBOX"
}
