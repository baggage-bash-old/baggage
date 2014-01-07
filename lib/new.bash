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

create_core_lib()
{
  local path="$1"
  local core_file="${path}/lib/core.bash"
  cat <<-'EOF' > "$core_file"
# Provides methods that used by projects

except() {
  local i=0
  local FRAMES=${#BASH_LINENO[@]}
  # FRAMES-2 skips main, the last one in arrays
  for ((i=FRAMES-2; i>=0; i--)); do
    echo '  File' \"${BASH_SOURCE[i+1]}\", line ${BASH_LINENO[i]}, in ${FUNCNAME[i+1]}
    # Grab the source code of the line
    sed -n -e "${BASH_LINENO[i]}{s/^/    /" -e 'p' -e '}' "${BASH_SOURCE[i+1]}"
  done
}

project_name()
{
  echo "$BAGGAGE_APP_NAME"
}

project_path()
{
  echo "$BAGGAGE_APP_PATH"
}

project_version()
{
  echo "$BAGGAGE_APP_VERSION"
}

project_description()
{
  echo "$BAGGAGE_APP_DESCRIPTION"
}


built?()
{
  if [ -n "$BAGGAGE_APP_BUILT" ]; then
    return 0
  else
    return 1
  fi
}


fatal()
{
  echo "FATAL - $1"
  except
  exit 1
}

require()
{
  local name="$1"
  [ -z "$name" ] && error "require argument missing"

  if built?; then
    $name
  else
    dir=$(find_root_path)
    if [ -r "${dir}/lib/${name}.bash" ]; then
      source "${dir}/lib/${name}.bash"
    elif [ -r "${dir}/bags/${name}.bag" ]; then
      source "${dir}/bags/${name}.bag"
    elif [ -d "${dir}/bags/${name}" ] && [ -r "${dir}/bags/${name}/out/${name}.bag" ]; then
      source "${dir}/bags/${name}/out/${name}.bag"
    fi
  fi
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

require example
total=0
while [ \$# -gt 0 ]; do
  total=\$(add_two_numbers "\$total" "\$1")  
  shift
done
echo "Total: \$total"
EOF

  chmod +x "$bin_file"
}

thisisdumb()
{
  [ -r "$BAGGAGE_CONFIG_FILE" ] || fatal "Must be in baggage root dir"
  echo "Creating core lib"
  create_core_lib "./"
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
  create_core_lib "$new_app_path"
  create_example_lib "$new_app_path"
  create_example_bin "$name" "$new_app_path"
}
