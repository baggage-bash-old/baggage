#!/usr/bin/env bats

load ../lib/app

@test "app name" {
  run app_name
  # This isn't run from baggage
  [ "$output" = "bats-exec-test" ]
}

