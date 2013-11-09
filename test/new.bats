#!/usr/bin/env bats

load ../lib/new

@test "new without arguments" {
  run new
  [ "$status" -eq 1 ]
}

@test "create app dir" {

  tmp_dir=$(mktemp -d /tmp/baggage-XXXX)
  path="${tmp_dir}/baggage_new_test"

  run create_app_dir "$path"

  dir_created=0
  if [ -d "$path" ]; then
    dir_created=1
  fi

  rm -rf "$tmp_dir"

  [ "$status" -eq 0 ]
  [ "$dir_created" -eq 1 ]
}

@test "create sub directories" {

  tmp_dir=$(mktemp -d /tmp/baggage-XXXX)
  
  run create_sub_dirs "$tmp_dir"

  pushd "$tmp_dir"
  dirs=""; 
  for dir in *; do 
    dirs="${dirs}${dir},"
  done;
  echo $dirs
  popd

  rm -rf "$tmp_dir"

  [ "$status" -eq 0 ]
  [ "$dirs" = "bags,bin,ext,lib,out,test," ] 
}

@test "create baggage file" {

  tmp_dir=$(mktemp -d /tmp/baggage-XXXX)

  export BAGGAGE_CONFIG_FILE="Baggage"
  run create_baggage_file "$tmp_dir"

  found=0
  if [ -r "${tmp_dir}/${BAGGAGE_CONFIG_FILE}" ]; then
    found=1
  fi

  rm -rf "$tmp_dir"
  
  [ "$status" -eq 0 ]
  [ "$found" -eq 1 ]
}
