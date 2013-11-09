create_app_dir()
{
  local path="$1"
  if [ ! -d "$path" ]; then
    mkdir "$path"
  fi
}

create_sub_dirs()
{
  local path="$1"
  for dir in bags bin ext lib out test; do
    mkdir "${path}/${dir}"
  done
}

create_baggage_file()
{
  local name="$1"
  local path="$2"
  file="${path}/${BAGGAGE_CONFIG_FILE}"

  cat <<-EOF > "$file"
name        "$name"
version     "0.1.0"
description "Add your description"

# We really want this ext so we can use it to test
# bags as we install them. Remove it at your peril.

ext bats https://github.com/sstephenson/bats.git

# Add your bags here

# From git
# bag http://github.com/auser/baggage-ssh.git
# Or from a local tar
# bag /home/auser/baggage-web.tar.gz
# Or from a local directory
# bag /home/auser/baggage-fs
# Or from a local directory in the baggage dir
# bag my_baggage
EOF
}

create_example_test()
{
  local path="$1"
  local test_file="${path}/test/example.bats"

  cat <<-EOF > "$test_file"
#!/usr/bin/env bats

# See https://github.com/sstephenson/bats for more info

@test "add two numbers" {
  load ../lib/example
  run add_two_numbers 2 2
  [ "\$output" -eq 4 ]
}
EOF
}

create_example_lib()
{
  local path="$1"
  local lib_file="${path}/lib/example.bash"

  cat <<-EOF > "$lib_file"
add_two_numbers()
{
  echo "\${1}+\${2}" | bc
}
EOF
}

create_example_bin()
{
  local name="$1"
  local path="$2"
  local bin_file="${path}/bin/${name}"

  cat <<-EOF > "$bin_file"
#!/bin/bash
set -e

# TODO - provide basic stuff
# load example
source lib/example.bash

total=0
while [ \$# -gt 0 ]; do
  total=\$(add_two_numbers "\$total" "\$1")  
  shift
done
echo "Total: \$total"
EOF

  chmod +x "$bin_file"
}

new()
{
  local name=$1
  local path=${2:-"./"}

  if [ -z "$name" ]; then
    error "oops"
    return 1
  fi
  
  local new_app_path="${path}/${name}" 

  create_app_dir "$new_app_path"
  create_sub_dirs "$new_app_path"
  create_baggage_file "$name" "$new_app_path"
  create_example_test "$new_app_path"
  create_example_lib "$new_app_path"
  create_example_bin "$name" "$new_app_path"
}
