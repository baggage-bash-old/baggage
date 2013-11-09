#!/usr/bin/env bats

load ../lib/build

@test "build" {
  skip
  run build
  [ "$status" -eq 0 ]
}

