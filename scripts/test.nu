#!/usr/bin/env nu

def "main" [] {
  nu -c $"($env.FILE_PWD)/test.nu -h"
}

def "main start" []: nothing -> nothing {
  pueued -d
  sleep 1sec
  pueue add vault server -dev -dev-root-token-id=root 
  sleep 1sec
}

def "main stop" []: nothing -> nothing {
  try { pueue reset -f }
  sleep 1sec
  try { pueue shutdown }
  sleep 1sec
}

def "main all" [root: string]: nothing -> nothing {
  main stop
  main start
  for test in (ls $"($root)/test") {
    let test = $test.name | path basename
    test renew $root $test
  }
}

def "main one" [root: string, test: string]: nothing -> nothing {
  main stop
  main start
  test renew $root $test
}

def "test renew" [root: string, test: string]: nothing -> nothing {
  rm -rf $"($root)/test/($test)/artifacts"
  mkdir $"($root)/test/($test)/artifacts"
  cd $"($root)/test/($test)/artifacts"
  test $root $test
  test $root $test
}

def "test" [root: string, test: string]: nothing -> nothing {
  let result = try {
    nu -c ($"($root)/src/main.nu"
      + $" ($root)/test/($test)/spec.toml"
      + " --stay"
      + " --keep")
      | complete
  }
  if ($result.exit_code != 0) {
    print $"Rumor failed with exit code '($result.exit_code)'"
    print $"Stdout:\n($result.stdout | decode if bytes)"
    print $"Stderr:\n($result.stderr | decode if bytes)"
    exit 1
  }

  let private_file = $"($root)/test/($test)/artifacts/sops.yaml"
  if (not ($private_file | path exists)) {
    print $"Secrets not generated for test '($test)'"
    exit 1
  }
  let private = open $private_file

  $env.SOPS_AGE_KEY_FILE = $"($root)/test/($test)/artifacts/age.txt"
  let decrypted_file = $"($root)/test/($test)/artifacts/sops.yaml.dec"
  let decrypted = (sops decrypt
    --input-type yaml
    --output-type yaml
    $"($root)/test/($test)/artifacts/sops.yaml.pub")
    | from yaml
  $decrypted
    | to yaml
    | save -f $decrypted_file

  if ($private != $decrypted) {
    let delta = delta $decrypted_file $private_file
    print $"Private doesn't match decrypted file in test '($test)'"
    print $"Decrypted:\n($decrypted | to yaml)"
    print $"Private:\n($private | to yaml)"
    print $"Delta \(decrypted -> private\):\n($delta)"
    exit 1
  }

  let snapshot_file = $"($root)/test/($test)/sops.yaml" 
  if ($snapshot_file | path exists) {
    let snapshot = open $snapshot_file
    let delta = snap $decrypted $snapshot

    if ($delta != null) {
      print $"Decrypted doesn't match snapshot file in test '($test)'"
      print $"Snapshot:\n($snapshot | to yaml)"
      print $"Decrypted:\n($decrypted | to yaml)"
      print $"Delta key: '($delta)'"
      exit 1
    }
  } else {
    print $"Snapshot file for test '($test)' not found"
    exit 1
  }
}

def snap [value: record, snapshot: record]: nothing -> string {
  let snapshot_transposed = $snapshot | transpose key value

  for pair in $snapshot_transposed {
    let key = $pair.key
    let snapshot_regex = $pair.value
    let value_value = $value | get --ignore-errors $key
    if ($value_value | is-empty) {
      return $key
    }

    if (($value_value | str replace -m -r $"^($snapshot_regex)$" "") != "") {
      return $key
    }
  }

  return null
}

def delta [minus: string, plus: string]: nothing -> string {
  (try { ^delta $minus $plus | complete }).stdout
}

def "decode if bytes" []: any -> string {
  if ($in | describe) == "string" {
    $in
  } else {
    $in | decode
  }
}
