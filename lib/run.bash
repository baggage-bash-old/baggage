run()
{
  load config
  
  source "./$BAGGAGE_CONFIG_FILE"
  
  # We're about to run the command, so pretend
  # we haven't been built
  built_flag_off

  command="bin/$(app_name)"

  if [ -r "$command" ]; then
    #exec "$command" $@
    source "$command"
  fi
}
