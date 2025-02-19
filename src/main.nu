#!/usr/bin/env -S nu --stdin

# TODO: better help

use std

let schema = $"($env.FILE_PWD)/schema.json"
let main = $"($env.FILE_PWD)/main.nu"

# run rumor with specification from path
def "main" [
  # path to specification
  spec: path,
  # stay in current working directory
  --stay,
  # don't remove the generated secrets
  --keep
]: nothing -> nothing {
  let specification = open $spec
  let validation_result = try {
   $specification
      | to json
      | json-schema-validate $schema
      | complete
  }
  if ($validation_result.exit_code != 0) {
    print --stderr $"Specification '($spec)' schema invalid"
    print --stderr $"Reason:\n($validation_result.stderr)"
    exit 1
  }

  run $specification $stay $keep
}

# run rumor with specification from stdin
def "main stdin" [
  # format of the specification
  format: string,
  # stay in current working directory
  --stay,
  # don't remove the generated secrets
  --keep
]: string -> nothing {
  let specification = if $format == "json" {
    $in | from json
  } else if $format == "yaml" {
    $in | from yaml
  } else if $format == "toml" {
    $in | from toml
  }

  let validation_result = try {
   $specification
      | to json
      | json-schema-validate $schema
      | complete
  }
  if ($validation_result.exit_code != 0) {
    print --stderr $"Stdin specification schema invalid"
    print --stderr $"Reason:\n($validation_result.stderr)"
    exit 1
  }

  run $specification $stay $keep
}

def "run" [specification, stay: bool, keep: bool]: nothing -> nothing {
  if not $stay {
    cd (mktemp -d)
  }

  for import in $specification.imports {
    mut command = $"($main) import ($import.importer)"
    mut stdin = ""

    if ($import.importer == "vault") {
      $command = $command + $" ($import.arguments.path)"
      if (($import.arguments | get --ignore-errors allow_fail) != null
        and $import.arguments.allow_fail) {
        $command = $command + $" --allow-fail"
      }
    } else if ($import.importer == "copy") {
      $command = $command + $" ($import.arguments.from)"
      $command = $command + $" ($import.arguments.to)"
      if (($import.arguments | get --ignore-errors allow_fail) != null
        and $import.arguments.allow_fail) {
        $command = $command + $" --allow-fail"
      }
    }

    if ($stdin | is-not-empty) {
      $stdin | nu --stdin -c $command
    } else {
      nu -c $command
    }
  }

  for generation in $specification.generations {
    mut command = $"($main) generate ($generation.generator)"
    mut stdin = ""
    if $generation.generator == "id" {
      $command = $command + $" ($generation.arguments.name)" 
      if (($generation.arguments | get --ignore-errors length) != null) {
        $command = $command + $" --length ($generation.arguments.length)"
      }
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "key" {
      $command = $command + $" ($generation.arguments.name)" 
      if (($generation.arguments | get --ignore-errors length) != null) {
        $command = $command + $" --length ($generation.arguments.length)"
      }
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "pin" {
      $command = $command + $" ($generation.arguments.name)" 
      if (($generation.arguments | get --ignore-errors length) != null) {
        $command = $command + $" --length ($generation.arguments.length)"
      }
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "mkpasswd" {
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      if (($generation.arguments | get --ignore-errors length) != null) {
        $command = $command + $" --length ($generation.arguments.length)"
      }
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "age" {
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "ssh-keygen" {
      $command = $command + $" ($generation.arguments.name)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "nebula-ca" {
      $command = $command + $" ($generation.arguments.name)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      if (($generation.arguments | get --ignore-errors days) != null) {
        $command = $command + $" --days ($generation.arguments.days)"
      }
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "nebula" {
      $command = $command + $" ($generation.arguments.ca_public)" 
      $command = $command + $" ($generation.arguments.ca_private)" 
      $command = $command + $" ($generation.arguments.name)" 
      $command = $command + $" ($generation.arguments.ip)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "openssl-ca" {
      $command = $command + $" ($generation.arguments.name)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      if (($generation.arguments | get --ignore-errors days) != null) {
        $command = $command + $" --days ($generation.arguments.days)"
      }
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "openssl" {
      $command = $command + $" ($generation.arguments.ca_public)" 
      $command = $command + $" ($generation.arguments.ca_private)" 
      $command = $command + $" ($generation.arguments.serial)" 
      $command = $command + $" ($generation.arguments.name)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      if (($generation.arguments | get --ignore-errors days) != null) {
        $command = $command + $" --days ($generation.arguments.days)"
      }
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "env" {
      $command = $command + $" ($generation.arguments.name)" 
      $command = $command + $" json" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
      $stdin = $generation.arguments.variables | to json
    } else if $generation.generator == "moustache" {
      $command = $command + $" ($generation.arguments.name)" 
      $command = $command + $" json" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
      $stdin = {
        variables: $generation.arguments.variables
        template: $generation.arguments.template
      } | to json
    } else if $generation.generator == "sops" {
      $command = $command + $" ($generation.arguments.age)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      $command = $command + $" json" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
      $stdin = $generation.arguments.secrets | to json
    }

    if ($stdin | is-not-empty) {
      $stdin | nu --stdin -c $command
    } else {
      nu -c $command
    }
  }

  for export in $specification.exports {
    mut command = $"($main) export ($export.exporter)"
    mut stdin = ""

    if ($export.exporter == "vault") {
      $command = $command + $" ($export.arguments.path)"
    } else if ($export.exporter == "copy") {
      $command = $command + $" ($export.arguments.from)"
      $command = $command + $" ($export.arguments.to)"
    }

    if ($stdin | is-not-empty) {
      $stdin | nu --stdin -c $command
    } else {
      nu -c $command
    }
  }

  if not $keep {
    rm -rf ./*
  }
}

def "main import copy" [
  from: path,
  to: path,
  --allow-fail
]: nothing -> nothing {
  if $allow_fail {
    try {
      cp -f $from $to
    }
  } else {
    cp -f $from $to
  }
}

def "main import vault" [
  path: string,
  --allow-fail
]: nothing -> nothing {
  let last_component = $path
    | str trim --char "/"
    | split row "/"
    | last

  let result = if $allow_fail {
      let result = try { medusa export $path | complete }
      if ($result.exit_code != 0) {
        return
      }
      $result.stdout
    } else {
      medusa export $path
    }

  let files = $result
    | from yaml
    | get $last_component
    | get current
    | transpose name value
  for file in $files {
    $file.value | save -f $file.name 
  }
}

def "main export copy" [
  from: path,
  to: path
]: nothing -> nothing {
  cp -f $from $to
}

def "main export vault" [
  path: string
]: nothing -> nothing {
  let trimmed_path = $path | str trim --char '/'

  let files = ls
    | each { |file|
        {
          name: ($file.name | path basename),
          value: (open --raw $file.name | str trim)
        }
      }
    | transpose -r -d --ignore-titles
    | to yaml

  let path = $trimmed_path + "/current"
  $files | medusa import $path -

  let time = date now | format date "%Y%m%d%H%M%S"
  let timestamped_path = $"($trimmed_path)/($time)"
  $files | medusa import $timestamped_path -
}

def "main generate pin" [
  name: path,
  --length: int = 8
  --renew
]: nothing -> nothing {
  let pin = (0..($length - 1))
    | each { |_| random int 0..9 }
    | str join ""
  if $renew {
    $pin | save -f $"($name)"
  } else {
    $pin | try { save $"($name)" }
  }
  chmod 600 $"($name)"
}

def "main generate key" [
  name: path,
  --length: int = 32,
  --renew
]: nothing -> nothing {
  let id = random chars --length $length
  if $renew {
    $id | save -f $name
  } else {
    $id | try { save $name }
  }
  chmod 600 $name
}

def "main generate id" [
  name: path,
  --length: int = 16,
  --renew
]: nothing -> nothing  {
  let id = random chars --length $length
  if $renew {
    $id | save -f $name
  } else {
    $id | try { save $name }
  }
  chmod 644 $name
}

def "main generate mkpasswd" [
  public: path,
  private: path,
  --length: int = 8,
  --renew
]: nothing -> nothing {
  let pass = random chars --length $length
  # NOTE: setting algorithm here so output is at least somewhat deterministic
  let encrypted = $pass | mkpasswd --stdin --method=yescrypt

  if $renew {
    $pass | save -f $private
  } else {
    $pass | try { save $private }
  }
  chmod 600 $private

  if $renew {
    $encrypted | save -f $public
  } else {
    $encrypted | try { save $public }
  }
  chmod 644 $public
}

def "main generate age" [
  public: string,
  private: string,
  --renew
]: nothing -> nothing {
  age-keygen err> (std null-device) out> $"($private)-temp"
  open --raw $"($private)-temp"
    | (age-keygen -y
      err> (std null-device)
      out> $"($public)-temp")

  if $renew {
    mv -f $"($private)-temp" $private
  } else {
    try { mv -n $"($private)-temp" $private }
  }
  rm -f $"($private)-temp"
  chmod 600 $private

  if $renew {
    mv -f $"($public)-temp" $public
  } else {
    try { mv -n $"($public)-temp" $public }
  }
  rm -f $"($public)-temp"
  chmod 644 $public
}

def "main generate ssh-keygen" [
  name: string,
  public: path,
  private: path,
  --renew
]: nothing -> nothing {
  (ssh-keygen
    -a 100
    -t ed25519
    -C $name
    -N ""
    -f $"($private)-temp")
  mv -f $"($private)-temp.pub" $"($public)-temp"

  if $renew {
    mv -f $"($private)-temp" $private
  } else {
    try { mv -n $"($private)-temp" $private }
  }
  rm -f $"($private)-temp"
  chmod 600 $private

  if $renew {
    mv -f $"($public)-temp" $public
  } else {
    try { mv -n $"($public)-temp" $public }
  }
  rm -f $"($public)-temp"
  chmod 644 $public
}

def "main generate openssl-ca" [
  name: string,
  public: path,
  private: path,
  --days: int = 3650,
  --renew
]: nothing -> nothing {
  (openssl genpkey -algorithm ED25519
    -out $"($private)-temp")

  (openssl req -x509
    -key $"($private)-temp"
    -out $"($public)-temp"
    -subj $"/CN=($name)"
    -days $days)

  if $renew {
    mv -f $"($private)-temp" $private
  } else {
    try { mv -n $"($private)-temp" $private }
  }
  rm -f $"($private)-temp"
  chmod 600 $private

  if $renew {
    mv -f $"($public)-temp" $public
  } else {
    try { mv -n $"($public)-temp" $public }
  }
  rm -f $"($public)-temp"
  chmod 644 $public
}

def "main generate openssl" [
  ca_public: path,
  ca_private: path,
  serial: path,
  name: string,
  public: path,
  private: path,
  --days: int = 3650
  --renew
]: nothing -> nothing {
  (openssl genpkey -algorithm ED25519
    -out $"($private)-temp")

  (openssl req -new
    -key $"($private)-temp"
    -out $"($private)-temp.req"
    -subj $"/CN=($name)")

  if ($serial | path exists) {
    cp $serial $"($serial)-temp"
    (openssl x509 -req
      -in $"($private)-temp.req"
      -CA $ca_public
      -CAkey $ca_private
      -CAserial $"($serial)-temp"
      -out $"($public)-temp"
      -days $days)
  } else {
    (openssl x509 -req
      -in $"($private)-temp.req"
      -CA $ca_public
      -CAkey $ca_private
      -CAcreateserial
      -out $"($public)-temp"
      -days $days)
    mv $"($ca_public).srl" $"($serial)-temp" 
  }

  rm -f $"($private)-temp.req"

  if $renew {
    mv -f $"($serial)-temp" $serial
  } else {
    try { mv -n $"($serial)-temp" $serial }
  }
  rm -f $"($serial)-temp"
  chmod 600 $serial

  if $renew {
    mv -f $"($private)-temp" $private
  } else {
    try { mv -n $"($private)-temp" $private }
  }
  rm -f $"($private)-temp"
  chmod 600 $private

  if $renew {
    mv -f $"($public)-temp" $public
  } else {
    try { mv -n $"($public)-temp" $public }
  }
  rm -f $"($public)-temp"
  chmod 644 $public
}

def "main generate nebula-ca" [
  name: string,
  public: path,
  private: path,
  --days: int = 3650,
  --renew
]: nothing -> nothing {
  (nebula-cert ca
    -name $name
    -duration $"($days * 24)h"
    -out-crt $"($public)-temp"
    -out-key $"($private)-temp")

  if $renew {
    mv -f $"($private)-temp" $private
  } else {
    try { mv -n $"($private)-temp" $private }
  }
  rm -f $"($private)-temp"
  chmod 600 $private

  if $renew {
    mv -f $"($public)-temp" $public
  } else {
    try { mv -n $"($public)-temp" $public }
  }
  rm -f $"($public)-temp"
  chmod 644 $public
}

def "main generate nebula" [
  ca_public: path,
  ca_private: path,
  name: string,
  ip: string,
  public: path,
  private: path,
  --renew
]: nothing -> nothing {
  (nebula-cert sign
    -ca-crt $ca_public
    -ca-key $ca_private
    -name $name
    -ip $ip
    -out-crt $"($public)-temp"
    -out-key $"($private)-temp")

  if $renew {
    mv -f $"($private)-temp" $private
  } else {
    try { mv -n $"($private)-temp" $private }
  }
  rm -f $"($private)-temp"
  chmod 600 $private

  if $renew {
    mv -f $"($public)-temp" $public
  } else {
    try { mv -n $"($public)-temp" $public }
  }
  rm -f $"($public)-temp"
  chmod 644 $public
}

def "main generate env" [
  name: string,
  format: string,
  --renew    
]: string -> nothing {
  let vars = if $format == "json" {
    $in | from json
  } else if $format == "yaml" {
    $in | from yaml
  } else if $format == "toml" {
    $in | from toml
  }

  let vars = $vars
    | transpose key value
    | each { |pair|
        let value = open --raw $pair.value
          | str trim
          | str replace -a "\n" "\\n"
          | str replace -a "\\" "\\\\"
          | str replace -a "\"" "\\\""
        {
          key: $pair.key,
          value: $value
        }
      }
    | reduce --fold "" { |item, accumulator|
        $"($accumulator)\n($item.key)=\"($item.value)\""
      }
    | str trim

  if $renew {
    $vars | save -f $name
  } else {
    $vars | try { save $name }
  }
  chmod 600 $name
}

def "main generate moustache" [
  name: string,
  format: string,
  --renew    
]: string -> nothing {
  let args = if $format == "json" {
    $in | from json
  } else if $format == "yaml" {
    $in | from yaml
  } else if $format == "toml" {
    $in | from toml
  }

  let vars = $args.variables
    | transpose key value
    | each { |pair|
        let value = open --raw $pair.value
          | str trim
          | str replace -a "\n" "\\n"
          | str replace -a "\\" "\\\\"
          | str replace -a "\"" "\\\""
        {
          key: $pair.key,
          value: $value
        }
      }
    | reduce --fold "" { |item, accumulator|
        $"($accumulator) ($item.key)=\"($item.value)\""
      }
    | str trim

  $args.template | str trim | save -f $"($name)-temp"
  let command = $"env ($vars) mo '($name)-temp' | collect | save -f ($name)-temp"
  nu -c $command

  if $renew {
    mv -f $"($name)-temp" $name
  } else {
    try { mv -n $"($name)-temp" $name }
  }
  rm -f $"($name)-temp"
  chmod 600 $name
}

def "main generate sops" [
  age: string,
  public: string,
  private: string,
  format: string,  
  --renew
]: string -> nothing {
  let values = if $format == "json" {
    $in | from json
  } else if $format == "yaml" {
    $in | from yaml
  } else if $format == "toml" {
    $in | from toml
  }

  let values = $values
    | transpose key value
    | each { |secret|
        {
          key: $secret.key,
          value: (open --raw $secret.value | str trim)
        }
      }
    | transpose -r -d --ignore-titles

  $values | to yaml | save -f $"($private)-temp"

  (sops encrypt $"($private)-temp"
    --input-type yaml
    --age (open --raw $age)
    --output $"($public)-temp"
    --output-type yaml)

  if $renew {
    mv -f $"($private)-temp" $private
  } else {
    try { mv -n $"($private)-temp" $private }
  }
  rm -f $"($private)-temp"
  chmod 600 $private

  if $renew {
    mv -f $"($public)-temp" $public
  } else {
    try { mv -n $"($public)-temp" $public }
  }
  rm -f $"($public)-temp"
  chmod 644 $public
}
