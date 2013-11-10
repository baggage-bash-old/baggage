built?()
{
  if [ -n "$BAGGAGE_APP_BUILT" ]; then
    return 0
  else
    return 1
  fi
}

info()
{
  echo "INFO - $1"
}

warn()
{
  echo "WARN - $1"
}

error()
{
  echo "ERROR - $1"
}

fatal()
{
  echo "FATAL - $1"
  exit 1
}

load()
{
  local name="$1"
  [ -z "$name" ] && error "load argument missing"

  if built?; then
    $name
  else
    if [ -r "lib/${name}.bash" ]; then
      source "lib/${name}.bash"
    fi
  fi
}
