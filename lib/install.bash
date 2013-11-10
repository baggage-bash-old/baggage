load config

map_source_to_command()
{
  src="$1"

  cmd=""
  if [ "${src:(-3)}" = "git" ]; then
    cmd="git"
  elif [ "${src:0:4}" = "http" ]; then
    cmd="http"
  elif [ "${src:(-7)}" = ".tar.gz" ]; then
    cmd="targz"
  elif [ "${src:(-3)}" = ".gz" ]; then
    cmd="gz"
  elif [ -d "$src" ]; then
    cmd="dir"
  elif [ -f "$src" ]; then
    cmd="file"
  else
    cmd="unknown"
  fi

  echo "get_${cmd}"
}

get_git()
{
  src="$1"
  dest="$2"

  echo "Cloning from $src"
  git clone "$src" "$dest"
}

get_http()
{
  src="$1"
  dest="$2"
}

get_targz()
{
  src="$1"
  dest="$2"

}

get_gz()
{
  src="$1"
  dest="$2"

}

get_dir()
{
  src="$1"
  dest="$2"

}

get_file()
{
  src="$1"
  dest="$2"

}

get()
{
  dest="$1"
  name="$2"
  src="$3"
  dir="$dest/$name"

  echo "Installing $name"

  [ ! -d "$dir" ] && mkdir "$dir"

  command=$(map_source_to_command "$src")

  # Just use github for now
  $command "$src" "$dir"
}

bag()
{
  [ -d "bags" ] || mkdir bags
  get "bags" $@
}

ext()
{
  [ -d "ext" ] || mkdir ext
  get "ext" $@
}

install()
{
  source "./$BAGGAGE_CONFIG_FILE"
}
