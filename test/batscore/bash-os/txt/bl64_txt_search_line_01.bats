setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  export input="$TESTMANSH_TEST_SAMPLES/text_lines_01.txt"
}

@test "bl64_txt_search_line: file, line is present" {
  line='second line'
  run bl64_txt_search_line "$input" "$line"
  assert_success
}

@test "bl64_txt_search_line: file, line is not present" {
  line='not present'
  run bl64_txt_search_line "$input" "$line"
  assert_failure
}

@test "bl64_txt_search_line: stdin, line is present" {
  line='second line'
  cat "$input" | bl64_txt_search_line "$BL64_TXT_FLAG_STDIN" "$line"
}
