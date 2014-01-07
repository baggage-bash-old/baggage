run_spec()
{
  dir=$(find_root_path)
  if [ -r "${dir}/${VAGRANT_FILE}" ]; then
    which -s vagrant
    if [ "$?" -eq "0" ]; then
      vagrant up
    else
      fatal "Vagrant doesn't seem to be installed"
    fi
  fi
}

run_spec_tests()
{
  #in_baggage_root?
  dir=$(find_root_path)

  # Run bats tests
  bats_file="${dir}/ext/bats/bin/bats"
  if [ -x "$bats_file" ]; then
    $bats_file spec/*.bats
  fi
}
