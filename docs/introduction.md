# Rumor

A small tool for generating, encrypting, and managing secrets.

Rumor allows you to create and renew secrets using a specification. The
specification contains instructions for Rumor for how to import existing
secrets, generate or renew secrets and export those secrets in that order.

All imports, generations and exports happen in the order of execution as
specified in the specification.

## Installation

Rumor is available as the default nix package of the [Rumor flake]. Rumor is supported
on all default systems.

## Invoking

You can invoke Rumor in two ways:

1. `rumor <path>`: This tells Rumor to load the specification from the given
   path. Supported formats are json, yaml and toml. Rumor automatically detects
   the format of the specification via the file extension.
2. `... | rumor stdin <format>`: This tells Rumor to load the specification from
   standard input. In this mode you have to tell Rumor the format of the
   specification.

In both modes, rumor has two optional arguments:

- `--stay`: By default, Rumor will create a temporary directory and change its
  directory to it. You can instruct Rumor to stay in the directory in which it
  was invoked by passing this argument.
- `--keep`: By default, Rumor will delete the contents of the working directory
  at the end of its execution. This is a safety precaution so that your
  filesystem doesn't contain secrets in plaintext for anyone to see after it is
  done with work. You can disable this behavior by passing this argument.

Rumor also allows you to invoke all of the importers, generators and exporters
on their own which will be described in the following chapters. Please note,
however, that while rumor does some have safety precautions when using it in the
main two ways as described here, invoking the importers, generators and
exporters by themselves is done with minimal safety precautions which is limited
to setting file permissions on generated files.

## Specification

Here is an example of the specification in TOML format:

```toml
[[imports]]
importer = "copy"
arguments.path = "../id"
arguments.to = "id"
arguments.allow_fail = true

[[imports]]
importer = "copy"
arguments.from = "../key"
arguments.to = "key"
arguments.allow_fail = true

[[generations]]
generator = "id"
arguments.name = "id"
arguments.length = 16

[[generations]]
generator = "key"
arguments.name = "key"
arguments.length = 32
arguments.renew = true

[[exports]]
exporter = "copy"
arguments.from = "id"
arguments.to = "../id"

[[exports]]
exporter = "copy"
arguments.from = "key"
arguments.to = "../key"
```

This specification will instruct Rumor to do the following:

1. Copy the `../id` and then `../key` files into the working directory while
   allowing Rumor to fail if the files do not exist (useful when generating
   secrets for the first time) time)

2. Generate the `id` file with the contents of a alphanumeric identifier of
   length 16 if it doesn't exist

3. Generate the `key` file with the contents of a alphanumeric key of length 32
   overwriting the original if it exists (renewal)

4. Copy the `id` file into `../id` and then the `key` file into `../key`
   overwriting the original files if they exist

Rumor validates every specification against the [schema.json] file.

[schema.json]: https://github.com/altibiz/rumor/blob/main/src/schema.json
[Rumor flake]: https://github.com/altibiz/rumor
