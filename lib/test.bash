# Runs tests
run_tests()
{
  in_baggage_root?

  # Run bats tests
  bats_file="./ext/bats/bin/bats"
  if [ -x "$bats_file" ]; then
    $bats_file test/*.bats
  fi
}
