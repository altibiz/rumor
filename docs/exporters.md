# Exporters

The following are all available exporters in Rumor. The type corresponds to the
`exporter` field in the specification.

## Copy

Uses `cp -f` to copy a file.

- Type: `copy`
- Arguments:
  - `from` (`path`): From where to copy the file.
  - `to` (`path`): Where to put the file.

## Vault

Uses [`medusa`] to export multiple files to [Vault].

- Type: `vault`
- Arguments:
  - `path` (`string`): [Vault] path where to export files to. The `path` will
    get suffixed with a `current` key and a numeric key containing the current
    timestamp to allow Rumor to save multiple versions of the same secrets.

## Vault file

Uses [Vault] CLI to export a single file to [Vault].

- Type: `vault`
- Arguments:
  - `path` (`string`): [Vault] path where to export files to. The `path` will
    get suffixed with a `current` key and a numeric key containing the current
    timestamp to allow Rumor to save multiple versions of the same secrets. If
    the `path` is already present it patches the current file and makes a new
    timestamped version of the whole `path`. If the file is not present, it
    makes a new secret at `path` with current and timestamped suffixes for
    versioning.
  - `file` (`string`): Key of the file to export.

[`medusa`]: https://github.com/jonasvinther/medusa
[Vault]: https://www.vaultproject.io/
