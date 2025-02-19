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

[`medusa`]: https://github.com/jonasvinther/medusa
[Vault]: https://www.vaultproject.io/
