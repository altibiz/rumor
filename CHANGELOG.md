<!-- markdownlint-disable MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and adheres to [Semantic Versioning](https://semver.org/).

## [2.0.1] - 2025-05-24

## Changed

- switch to OpenSSL ECDSA P-256 (prime256v1) instead of Ed25519 for better
  browser compatibility

## [2.0.1] - 2025-05-21

### Added

- docs for `openssl-dhparam` generator

### Changed

- fix OpenSSL serial generation in certain scenarios
- fix `rumor` not exporting anything
- fix `dhparam` test wrong vault path

## [2.0.0] - 2025-05-20

### Added

- `copy`, `text`, `json`, `toml`, `yaml`, `openssl-dhparam` generators
- `config` argument to `openssl` and `openssl-ca` generators

### Changed

- Script commands take not CLI-friendly arguments from files and not from stdin

### Removed

- `name` argument for `openssl` and `openssl-ca` generators in favor of the new
  `config` argument

## [1.3.1] - 2025-05-19

### Changed

- Test environment variable fixes
- Vault file importer fix when the path exists but file doesn't with
  `allow_fail`
- Small `cockroach` test fix

## [1.3.0] - 2025-05-18

### Added

- Cockroachdb client certificate user name configuration

## [1.2.0] - 2025-03-30

### Added

- Cockroachdb CA, node and user certificate generation

## [1.1.3] - 2025-02-27

### Changed

- Fixed `vault` importer not extracting correct value from `medusa`

## [1.1.2] - 2025-02-26

### Changed

- Fixed nix package coreutils dependency

## [1.1.1] - 2025-02-26

### Changed

- Fixed nix package PATH environment variable

## [1.1.0] - 2025-02-25

### Added

- Vault file importer
- Vault file exporter

### Changed

- If environment generator variable file is not present, put literal value
- If Moustache template generator variable file is not present, make literal
  value available
- If SOPS generator variable file is not present, put literal value

## [1.0.0] - 2025-02-21

### Added

- initial script, package, documentation and tests

[2.0.1]: https://github.com/altibiz/rumor/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/altibiz/rumor/compare/1.3.1...2.0.0
[1.3.1]: https://github.com/altibiz/rumor/compare/1.3.0...1.3.1
[1.3.0]: https://github.com/altibiz/rumor/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/altibiz/rumor/compare/1.1.3...1.2.0
[1.1.3]: https://github.com/altibiz/rumor/compare/1.1.2...1.1.3
[1.1.2]: https://github.com/altibiz/rumor/compare/1.1.1...1.1.2
[1.1.1]: https://github.com/altibiz/rumor/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/altibiz/rumor/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/altibiz/rumor/releases/tag/1.0.0
