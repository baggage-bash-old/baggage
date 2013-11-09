add_header()
{
  local header="$1"
  local app_file="$2"

  echo -e "\n################################################################################" >> "$app_file"
  echo "# $header" >> "$app_file"
  echo -e "################################################################################\n" >> "$app_file"
}

open_method()
{
  local name="$1"
  local app_file="$2"

  echo "${name}()" >> "$app_file"
  echo "{" >> "$app_file"
}

close_method()
{
  local name="$1"
  local app_file="$2"

  echo "} # $name" >> "$app_file"
}

create_file()
{
  local app_file="$1"
  touch "$app_file"
  chmod +x "$app_file"
}

add_file()
{
  local source_file="$1"
  local app_file="$2"
  add_header "$source_file" "$app_file"
  cat $source_file >> "$app_file"
}

add_basics()
{
  local app_file="$1"
  cat <<-EOF > "$app_file"
#!/bin/bash
# Built $(date)
set -e

export BAGGAGE_APP_BUILT=1
export BAGGAGE_APP_NAME="$BAGGAGE_APP_NAME"
export BAGGAGE_APP_VERSION="$BAGGAGE_APP_VERSION"
export BAGGAGE_APP_DESCRIPTION="$BAGGAGE_APP_DESCRIPTION"

EOF
}

add_libs()
{
  local app_file="$1"

  [ ! -d lib ] && return

  for file in lib/*.bash; do
    name="$(basename ${file%.bash})"
    open_method "$name" "$app_file"
    add_file "$file" "$app_file"
    close_method "$name" "$app_file"
  done
}

add_bag()
{
  local bag_dir="$1"
  local app_file="$2"
}

add_bags()
{
  local app_file="$1"
  for dir in bags/*; do
    add_bag "$dir" "$app_file"
  done
}

add_bins()
{
  local app_file="$1"
  for file in bin/*; do
    add_file "$file" "$app_file"
  done
}

build()
{
  local app_file="$(pwd)/out/$(app_name)"
  local dest="$1"

  create_file "$app_file"
  add_basics "$app_file"
  add_libs "$app_file"
  add_bags "$app_file"
  add_bins "$app_file"

  if [ -n "$dest" ]; then
    output=$(cp "$app_file" "$dest" 2>&1)
    if [ "$?" -ne "0" ]; then
      if [ "$output" != "${output/Permission denied/}" ]; then
        # Try sudo
        sudo cp "$app_file" "$dest"
      else
        fatal "Could not install $app_file to $dest"
      fi
    fi 
  fi
}
