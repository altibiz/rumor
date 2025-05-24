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

    if ($import.importer == "vault") {
      $command = $command + $" ($import.arguments.path)"
      if (($import.arguments | get --ignore-errors allow_fail) != null
        and $import.arguments.allow_fail) {
        $command = $command + $" --allow-fail"
      }
    } else if ($import.importer == "vault-file") {
      $command = $command + $" ($import.arguments.path)"
      $command = $command + $" ($import.arguments.file)"
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

    nu -c $command
  }

  for generation in $specification.generations {
    mut command = $"($main) generate ($generation.generator)"
    if $generation.generator == "copy" {
      $command = $command + $" ($generation.arguments.from)" 
      $command = $command + $" ($generation.arguments.to)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "text" {
      $command = $command + $" ($generation.arguments.name)" 
      $command = $command + $" \"($generation.arguments.text | escape string)\"" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "json" {
      $command = $command + $" ($generation.arguments.name)" 
      let json = $"($generation.arguments.name)-json"
      $generation.arguments.value | to json | save -f $json
      $command = $command + $" json" 
      $command = $command + $" ($json)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "yaml" {
      $command = $command + $" ($generation.arguments.name)" 
      let yaml = $"($generation.arguments.name)-yaml"
      $generation.arguments.value | to yaml | save -f $yaml
      $command = $command + $" yaml" 
      $command = $command + $" ($yaml)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "toml" {
      $command = $command + $" ($generation.arguments.name)" 
      let toml = $"($generation.arguments.name)-toml"
      $generation.arguments.value | to toml | save -f $toml
      $command = $command + $" toml" 
      $command = $command + $" ($toml)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "id" {
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
    } else if $generation.generator == "cockroach-ca" {
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "cockroach" {
      $command = $command + $" ($generation.arguments.ca_public)" 
      $command = $command + $" ($generation.arguments.ca_private)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      $command = $command + $" ($generation.arguments.hosts | str join ",")"
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "cockroach-client" {
      $command = $command + $" ($generation.arguments.ca_public)" 
      $command = $command + $" ($generation.arguments.ca_private)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      $command = $command + $" ($generation.arguments.user)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "openssl-ca" {
      $command = $command + $" ($generation.arguments.config)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      if (($generation.arguments | get --ignore-errors days) != null) {
        $command = $command + $" --days ($generation.arguments.days)"
      }
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "openssl-dhparam" {
      $command = $command + $" ($generation.arguments.name)" 
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "openssl" {
      $command = $command + $" ($generation.arguments.ca_public)" 
      $command = $command + $" ($generation.arguments.ca_private)" 
      $command = $command + $" ($generation.arguments.serial)" 
      $command = $command + $" ($generation.arguments.config)" 
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
      let variables = $"($generation.arguments.name)-variables"
      $generation.arguments.variables | to json | save -f $variables
      $command = $command + $" ($variables)"
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "moustache" {
      $command = $command + $" ($generation.arguments.name)" 
      $command = $command + $" json" 
      let variables_and_template = $"($generation.arguments.name)-variables-and-template"
      {
        variables: $generation.arguments.variables
        template: $generation.arguments.template
      } | to json | save -f $variables_and_template
      $command = $command + $" ($variables_and_template)"
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    } else if $generation.generator == "sops" {
      $command = $command + $" ($generation.arguments.age)" 
      $command = $command + $" ($generation.arguments.public)" 
      $command = $command + $" ($generation.arguments.private)" 
      $command = $command + $" json" 
      let secrets = $"($generation.arguments.private)-secrets"
      $generation.arguments.secrets | to json | save -f $secrets
      $command = $command + $" ($secrets)"
      if (($generation.arguments | get --ignore-errors renew) != null
        and $generation.arguments.renew) {
        $command = $command + $" --renew"
      }
    }

    nu -c $command
  }

  for export in $specification.exports {
    mut command = $"($main) export ($export.exporter)"

    if ($export.exporter == "vault") {
      $command = $command + $" ($export.arguments.path)"
    } else if ($export.exporter == "vault-file") {
      $command = $command + $" ($export.arguments.path)"
      $command = $command + $" ($export.arguments.file)"
    } else if ($export.exporter == "copy") {
      $command = $command + $" ($export.arguments.from)"
      $command = $command + $" ($export.arguments.to)"
    }

    nu -c $command
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
    try { cp -n $from $to }
  } else {
    cp -f $from $to
  }
}

def "main import vault" [
  path: string,
  --allow-fail
]: nothing -> nothing {
  let trimmed_path = $path | str trim --char '/'

  let components = $trimmed_path
    | split row "/"
    | skip 1
    | into cell-path

  let result = if $allow_fail {
      let result = try {
        medusa export $trimmed_path
          | complete
      }
      if ($result.exit_code != 0) {
        return
      }
      $result.stdout | decode if bytes 
    } else {
      medusa export $path
    }

  let files = $result
    | from yaml
    | get $components
    | get current
    | transpose name value
  for file in $files {
    $file.value | save -f $file.name 
  }
}

def "main import vault-file" [
  path: string,
  file: string,
  --allow-fail
]: nothing -> nothing {
  let trimmed_path = $path | str trim --char '/'

  let result = if $allow_fail {
      let result = try {
        vault kv get -format=json $"($trimmed_path)/current"
          | complete
      }
      if ($result.exit_code != 0) {
        return
      }
      $result.stdout | decode if bytes
    } else {
      vault kv get -format=json $"($trimmed_path)/current"
    }

  let content = if $allow_fail {
    let content = $result
      | from json
      | get data
      | get data
      | get $file --ignore-errors
    if $content == null {
      return
    }
    $content
  } else {
    $result
      | from json
      | get data
      | get data
      | get $file
  }
  $content | save -f $file
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

def "main export vault-file" [
  path: string,
  file: string
]: nothing -> nothing {
  let trimmed_path = $path | str trim --char '/'
  let path = $trimmed_path + "/current"

  let content = open --raw $file | str trim

  let existing = (try { vault kv get -format=json $path | complete })
  let new = if $existing.exit_code == 0 {
    $existing.stdout
      | decode if bytes
      | from json
      | get data
      | get data
      | upsert $file $content
  } else {
    null
  }

  let time = date now | format date "%Y%m%d%H%M%S"
  let timestamped_path = $"($trimmed_path)/($time)"
  if $new == null {
    $content | vault kv put $path $"($file)=-"
    $content | vault kv put $timestamped_path $"($file)=-"
  } else {
    $content | vault kv patch $path $"($file)=-"
    $new | to yaml | medusa import $timestamped_path -
  }
}

def "main generate copy" [
  from: path,
  to: path,
  --renew
]: nothing -> nothing {
  if $renew {
    cp -f $from $to
  } else {
    try { cp -n $from $to }    
  }
}

def "main generate text" [
  name: path,
  text: string,
  --renew
]: nothing -> nothing {
  if $renew {
    $text | save -f $"($name)"
  } else {
    $text | try { save $"($name)" }
  }
  chmod 600 $"($name)"
}

def "main generate json" [
  name: path,
  format: string,
  json: string,
  --renew
]: nothing -> nothing {
  let json = if $format == "json" {
    open --raw $json
  } else if $format == "yaml" {
    open --raw $json | from yaml | to json
  } else if $format == "toml" {
    open --raw $json | from toml | to json
  }

  if $renew {
    $json | save -f $"($name)"
  } else {
    $json | try { save $"($name)" }
  }
  chmod 600 $"($name)"
}

def "main generate yaml" [
  name: path,
  format: string,
  yaml: string,
  --renew
]: nothing -> nothing {
  let yaml = if $format == "json" {
    open --raw $yaml | from json | to yaml
  } else if $format == "yaml" {
    open --raw $yaml
  } else if $format == "toml" {
    open --raw $yaml | from toml | to yaml
  }

  if $renew {
    $yaml | save -f $"($name)"
  } else {
    $yaml | try { save $"($name)" }
  }
  chmod 600 $"($name)"
}

def "main generate toml" [
  name: path,
  format: string,
  toml: path,
  --renew
]: nothing -> nothing {
  let toml = if $format == "json" {
    open --raw $toml | from json | to toml
  } else if $format == "yaml" {
    open --raw $toml | from yaml | to toml
  } else if $format == "toml" {
    open --raw $toml
  }

  if $renew {
    $toml | save -f $"($name)"
  } else {
    $toml | try { save $"($name)" }
  }
  chmod 600 $"($name)"
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
  config: string,
  public: path,
  private: path,
  --days: int = 3650,
  --renew
]: nothing -> nothing {
  (openssl genpkey
    -algorithm EC
    -pkeyopt ec_paramgen_curve:prime256v1
    -out $"($private)-temp")

  (openssl req -x509
    -key $"($private)-temp"
    -out $"($public)-temp"
    -config $config
    -extensions v3_ca
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

def "main generate openssl-dhparam" [
  name: path,
  --renew
]: nothing -> nothing {
  openssl dhparam -out $"($name)-temp" 2048
  if $renew {
    mv -f $"($name)-temp" $name
  } else {
    try { mv -n $"($name)-temp" $name }
  }
  rm -f $"($name)-temp"
  chmod 600 $name
}

def "main generate openssl" [
  ca_public: path,
  ca_private: path,
  serial: path,
  config: string,
  public: path,
  private: path,
  --days: int = 3650
  --renew
]: nothing -> nothing {
  (openssl genpkey
    -algorithm EC
    -pkeyopt ec_paramgen_curve:prime256v1
    -out $"($private)-temp")

  (openssl req -new
    -key $"($private)-temp"
    -out $"($private)-temp.req"
    -config $config)

  if ($serial | path exists) {
    cp $serial $"($serial)-temp"
    (openssl x509 -req
      -in $"($private)-temp.req"
      -CA $ca_public
      -CAkey $ca_private
      -CAserial $"($serial)-temp"
      -extfile $config
      -extensions ext
      -out $"($public)-temp"
      -days $days)
  } else {
    (openssl x509 -req
      -in $"($private)-temp.req"
      -CA $ca_public
      -CAkey $ca_private
      -CAcreateserial
      -CAserial $"($serial)-temp"
      -extfile $config
      -extensions ext
      -out $"($public)-temp"
      -days $days)
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

def "main generate cockroach-ca" [
  public: path,
  private: path,
  --renew
]: nothing -> nothing {
  rm -rf cockroach-temp
  mkdir cockroach-temp

  (cockroach cert create-ca
    --certs-dir=cockroach-temp
    --ca-key=cockroach-temp/ca.key)

  if $renew {
    mv -f $"cockroach-temp/ca.key" $private
  } else {
    try { mv -n $"cockroach-temp/ca.key" $private }
  }
  chmod 600 $private

  if $renew {
    mv -f $"cockroach-temp/ca.crt" $public
  } else {
    try { mv -n $"cockroach-temp/ca.crt" $public }
  }
  chmod 644 $public

  rm -rf cockroach-temp
}

def "main generate cockroach" [
  ca_public: path,
  ca_private: path,
  public: path,
  private: path,
  hosts: string,
  --renew
]: nothing -> nothing {
  rm -rf cockroach-temp
  mkdir cockroach-temp

  cp $ca_private cockroach-temp/ca.key
  cp $ca_public cockroach-temp/ca.crt

  (cockroach cert create-node
    ...($hosts | str trim | split row ",")
    --certs-dir=cockroach-temp
    --ca-key=cockroach-temp/ca.key)

  if $renew {
    mv -f $"cockroach-temp/node.key" $private
  } else {
    try { mv -n $"cockroach-temp/node.key" $private }
  }
  chmod 600 $private

  if $renew {
    mv -f $"cockroach-temp/node.crt" $public
  } else {
    try { mv -n $"cockroach-temp/node.crt" $public }
  }
  chmod 644 $public

  rm -rf cockroach-temp
}

def "main generate cockroach-client" [
  ca_public: path,
  ca_private: path,
  public: path,
  private: path,
  user: string,
  --renew
]: nothing -> nothing {
  rm -rf cockroach-temp
  mkdir cockroach-temp

  cp $ca_private cockroach-temp/ca.key
  cp $ca_public cockroach-temp/ca.crt

  (cockroach cert create-client
    $user
    --certs-dir=cockroach-temp
    --ca-key=cockroach-temp/ca.key)

  if $renew {
    mv -f $"cockroach-temp/client.($user).key" $private
  } else {
    try { mv -n $"cockroach-temp/client.($user).key" $private }
  }
  chmod 600 $private

  if $renew {
    mv -f $"cockroach-temp/client.($user).crt" $public
  } else {
    try { mv -n $"cockroach-temp/client.($user).crt" $public }
  }
  chmod 644 $public

  rm -rf cockroach-temp
}

def "main generate env" [
  name: string,
  format: string,
  vars: string,
  --renew
]: string -> nothing {
  let vars = if $format == "json" {
    open --raw $vars | from json
  } else if $format == "yaml" {
    open --raw $vars | from yaml
  } else if $format == "toml" {
    open --raw $vars | from toml
  }

  let vars = $vars
    | transpose key value
    | each { |pair|
        let raw = if ($pair.value | path exists) {
          open --raw $pair.value
        } else {
          $pair.value
        }
        let value = $raw
          | str trim
          | str replace -a "\\" "\\\\"
          | str replace -a "\n" "\\n"
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
  variables_and_template: path,
  --renew    
]: string -> nothing {
  let variables_and_template = if $format == "json" {
    open --raw $variables_and_template | from json
  } else if $format == "yaml" {
    open --raw $variables_and_template | from yaml
  } else if $format == "toml" {
    open --raw $variables_and_template | from toml
  }

  let vars = $variables_and_template.variables
    | transpose key value
    | each { |pair|
        let raw = if ($pair.value | path exists) {
          open --raw $pair.value
        } else {
          $pair.value
        }
        {
          key: $pair.key,
          value: ($raw | escape string)
        }
      }
    | reduce --fold "" { |item, accumulator|
        $"($accumulator) ($item.key)=\"($item.value)\""
      }
    | str trim

  $variables_and_template.template | str trim | save -f $"($name)-temp"
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
  values: path,
  --renew
]: string -> nothing {
  let values = if $format == "json" {
    open --raw $values | from json
  } else if $format == "yaml" {
    open --raw $values | from yaml
  } else if $format == "toml" {
    open --raw $values | from toml
  }

  let values = $values
    | transpose key value
    | each { |secret|
        let raw = if ($secret.value | path exists) {
          open --raw $secret.value
        } else {
          $secret.value
        }
        let value = $raw | str trim
        {
          key: $secret.key,
          value: $value
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

def "decode if bytes" []: any -> string {
  if ($in | describe) == "string" {
    $in
  } else {
    $in | decode
  }
}

def "escape string" []: string -> string {
  $in
    | str trim
    | str replace -a "\\" "\\\\"
    | str replace -a "\n" "\\n"
    | str replace -a "\"" "\\\""
}
