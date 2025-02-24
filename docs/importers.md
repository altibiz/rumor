# Importers

The following are all available importers in Rumor. The `type` corresponds to
the `importer` field in the specification.

## Copy

Uses `cp -f` to copy a file.

- Type: `copy`
- Arguments:
  - `from` (`path`): From where to copy the file.
  - `to` (`path`): Where to put the file.
  - `allow_fail` (`boolean`, `= false`): Allow failing to copy the file.

## Vault

Uses [`medusa`] to import multiple files from [Vault].

- Type: `vault`
- Arguments:
  - `path` (`string`): [Vault] path where to load files from. The `path` will
    get suffixed with a `current` key because it lets the corresponding `vault`
    exporter to export multiple versions of the same secrets.
  - `allow_fail` (`boolean`, `= false`): Allow failing to load files.

[`medusa`]: https://github.com/jonasvinther/medusa
[Vault]: https://www.vaultproject.io/
