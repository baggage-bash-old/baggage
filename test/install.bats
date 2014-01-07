#!/usr/bin/env bats

load ../lib/core
load ../lib/install

@test "command for git" {
  run map_source_to_command "git://github.com/blah/test.git"
  [ "$output" = "get_git" ]
}

@test "command for git http" {
  run map_source_to_command "http://github.com/blah/test.git"
  [ "$output" = "get_git" ]
}

@test "command for http" {
  run map_source_to_command "http://asite.com/download.tar.gz"
  [ "$output" = "get_http" ]
}

@test "command for tar.gz" {
  run map_source_to_command "/tmp/afile.tar.gz"
  [ "$output" = "get_targz" ]
}

@test "command for gz" {
  run map_source_to_command "/tmp/afile.gz"
  [ "$output" = "get_gz" ]
}

@test "command for dir" {
  tmp_dir=$(mktemp -d /tmp/baggage-XXXX)
  run map_source_to_command "$tmp_dir"
  rm -rf "$tmp_dir"
  [ "$output" = "get_dir" ]
}

@test "command for file" {
  tmp_file=$(mktemp /tmp/baggage-XXXX)
  run map_source_to_command "$tmp_file"
  rm "$tmp_file"
  [ "$output" = "get_file" ]
}
