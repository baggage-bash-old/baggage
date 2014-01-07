run()
{
  command_name="$1"

  require config
  dir=$(find_root_path)

  source "${dir}/${BAGGAGE_CONFIG_FILE}"

  # We're about to run the command, so pretend
  # we haven't been built
  built_flag_off

  if [ -n "$command_name" ] && [ -r "bin/${command_name}" ]; then
    command_file="${dir}/bin/${command_name}"
    shift
  else
    command_file="${dir}/bin/$(app_name)"
  fi

  if [ -r "$command_file" ]; then
    source "$command_file"
  else
    fatal "Cannot find $command_file"
  fi
}
