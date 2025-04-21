#!/usr/bin/env nu

def "main" [] {
  nu -c $"($env.FILE_PWD)/test.nu -h"
}

def "main start" []: nothing -> nothing {
  pueued -d
  mut ready = false
  while not $ready {
    print "Waiting for pueued..."
    let result = (try { pueue status | complete })
    if ($result.exit_code == 0) {
      print $"Pueued ready\n($result.stdout)"
      $ready = true
    } else {
      sleep 500ms
    }
  }
  (pueue add
    vault server
      -dev
      $"-dev-listen-address=($env.VAULT_DEV_ADDR)"
      -dev-root-token-id=root) 
  mut ready = false
  while not $ready {
    print "Waiting for vault..."
    let result = (try { 
      curl -s http://127.0.0.1:8201/v1/sys/health
      | complete
    })
    if ($result.exit_code == 0) {
      print $"Vault ready\n($result.stdout | from json | to json --indent 2)"
      $ready = true
    } else {
      sleep 500ms
    }
  }
}

def "main stop" []: nothing -> nothing {
  let result = (try { pueue status --json | complete })
  if ($result.exit_code != 0) {
    return
  }

  try { pueue reset -f }
  mut ready = false
  while not $ready {
    print "Waiting for pueued..."
    let result = (try { pueue status --json | complete })
    let json = $result.stdout | from json
    if (($result.exit_code == 0) and ($json.tasks | is-empty)) {
      print $"Pueued ready\n($json | to json --indent 2)"
      $ready = true
    } else {
      sleep 500ms
    }
  }
  try { pueue shutdown }
  mut ready = false
  while not $ready {
    print "Waiting for pueued..."
    let result = (try { pueue status --json | complete })
    let json = $result.stdout | from json
    if ($result.exit_code != 0) {
      print $"Pueued shutdown"
      $ready = true
    } else {
      sleep 500ms
    }
  }
}

def "main all" [root: string]: nothing -> nothing {
  main stop
  main start
  # TODO: add cockroach test
  let tests = ls $"($root)/test"
    | each { |test| $test.name | path basename }
    | where $it != "cockroach"
  print $"Running tests: ($tests | str join ', ')"
  for test in $tests {
    print $"Running test: ($test)"
    test renew $root $test
  }
}

def "main one" [root: string, test: string]: nothing -> nothing {
  main stop
  main start
  let tests = ls $"($root)/test" | each { |test| $test.name | path basename }
  if (not ($tests | any { |x| $x == $test })) {
    print $"Unknown test: ($test)"
    exit 1
  }
  print $"Running test: ($test)"
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
    nu -n -c ($"($root)/src/main.nu"
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
