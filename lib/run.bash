load config

run()
{
  source "./$BAGGAGE_CONFIG_FILE"

  command="bin/$(app_name)"

  if [ -r "$command" ]; then
    exec "$command" $@
  fi
}
