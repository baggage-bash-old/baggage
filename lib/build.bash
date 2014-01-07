add_header()
{
  local header="$1"
  local out_file="$2"

  echo -e "\n################################################################################" >> "$out_file"
  echo "# $header" >> "$out_file"
  echo -e "################################################################################\n" >> "$out_file"
}

open_method()
{
  local name="$1"
  local out_file="$2"

  echo "${name}()" >> "$out_file"
  echo "{" >> "$out_file"
}

close_method()
{
  local name="$1"
  local out_file="$2"

  echo "} # $name" >> "$out_file"
}

create_file()
{
  local out_file="$1"
  : > "$out_file"
  chmod +x "$out_file"
}

add_file()
{
  local source_file="$1"
  local out_file="$2"
  add_header "$source_file" "$out_file"
  cat $source_file >> "$out_file"
}

add_basics()
{
  local out_file="$1"
  cat <<-EOF >> "$out_file"
#!/bin/bash
# Built using http://baggage.io at $(date)
set -e

export BAGGAGE_APP_BUILT=1
export BAGGAGE_APP_NAME="$BAGGAGE_APP_NAME"
export BAGGAGE_APP_VERSION="$BAGGAGE_APP_VERSION"
export BAGGAGE_APP_DESCRIPTION="$BAGGAGE_APP_DESCRIPTION"

EOF
}

add_core()
{
  local out_file="$1"
  local file="lib/core.bash"

  [ -r "$file" ] || return 0
  name="$(basename $file)"

  add_file "$file" "$out_file"
}

add_lib()
{
  local lib_file="$1"
  local out_file="$2"
  local name="$(basename ${file%.bash})"

  add_header "$name" "$out_file"
  open_method "$name" "$out_file"
  add_file "$file" "$out_file"
  close_method "$name" "$out_file"
}

add_libs()
{
  local out_file="$1"

  [ -d lib ] || return 0

  for file in $(ls lib/*.bash 2>/dev/null); do
    # Skip core as we handle it elsewhere
    [ "$file" = "lib/core.bash" ] && continue    
    add_lib "$file" "$out_file"
  done
}

add_bag()
{
  local bag_dir="$1"
  local out_file="$2"

  local bag_name="$(basename $bag_dir)"
  local file="${bag_dir}/out/${bag_name}.bag"

  if [ ! -r "$file" ]; then
    pushd "$(dirname $bag_dir)" >/dev/null 2>&1
    $0 install && $0 build
    popd
  fi

  add_header "$name" "$out_file"
  open_method "$bag_name" "$out_file"
  add_file "$file" "$out_file"
  close_method "$bag_name" "$out_file"
}

add_bags()
{
  local out_file="$1"

  [ -d bags ] || return 0
  for dir in $(ls bags/* 2>/dev/null); do
    add_bag "$dir" "$out_file"
  done
}

add_bin()
{
  local bin_file="$1"
  local out_file="$2"

  add_file "$bin_file" "$out_file"
}

build_app()
{
  local dest="$1"

  [ -d bin ] || return 0
  for bin_file in $(ls bin/* 2>/dev/null); do
    bin_name="$(basename $bin_file)"

    local out_file="$(pwd)/out/${bin_name}"
    echo " Building app out/${bin_name}"

    create_file "$out_file"
    add_basics "$out_file"
    add_core "$out_file"
    add_bags "$out_file"
    add_libs "$out_file"
    add_bin "$bin_file" "$out_file"

    if [ -n "$dest" ]; then
      echo " Copying to $dest"
      output=$(cp "$out_file" "$dest" 2>&1)
      if [ "$?" -ne "0" ]; then
        if [ "$output" != "${output/Permission denied/}" ]; then
          # Try sudo
          sudo cp "$out_file" "$dest"
        else
          fatal "Could not install $out_file to $dest"
        fi
      fi 
    fi

  done
}

build_bag()
{
  local dest="$1"
  local bag_name="$(app_name)"
  local out_file="$(pwd)/out/$bag_name.bag"

  echo " Building bag out/$bag_name.bag"
  create_file "$out_file"
  open_method "$bag_name" "$out_file"
  add_bags "$out_file"
  add_libs "$out_file"
  close_method "$bag_name" "$out_file"
}

build()
{
  source "./$BAGGAGE_CONFIG_FILE"
  local dest="$1"
  
  build_app "$dest"
  build_bag "$dest"
}
