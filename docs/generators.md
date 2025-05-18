# Generators

The following are all available generators in Rumor. The `type` corresponds to
the `generator` field in the specification.

## Id

Generates an alphanumeric identifier with `644` permissions.

- Type: `id`
- Arguments:
  - `name` (`path`): Path where to save the identifier.
  - `length` (`number`, `= 16`, `> 0`): Length of the identifier.
  - `renew` (`boolean`, `= false`): Whether to renew the identifier upon
    subsequent generations.

## Key

Generates an alphanumeric key with `600` permissions.

- Type: `key`
- Arguments:
  - `name` (`path`): Path where to save the key.
  - `length` (`number`, `= 32`, `> 0`): Length of the key.
  - `renew` (`boolean`, `= false`): Whether to renew the key upon subsequent
    generations.

## Pin

Generates a numeric pin with `600` permissions.

- Type: `pin`
- Arguments:
  - `name` (`path`): Path where to save the pin.
  - `length` (`number`, `= 8`, `> 0`): Length of the pin.
  - `renew` (`boolean`, `= false`): Whether to renew the pin upon subsequent
    generations.

## Linux password

Generates an alphanumeric `mkpasswd` linux user password with `600` permissions
for the plaintext part and `644` for the encrypted part. Uses `yescrypt` for the
encryption algorithm.

- Type: `pin`
- Arguments:
  - `private` (`path`): Path where to save the plaintext password.
  - `public` (`path`): Path where to save the encrypted password.
  - `length` (`number`, `= 8`, `> 0`): Length of the password.
  - `renew` (`boolean`, `= false`): Whether to renew the password upon
    subsequent generations.

## Age key

Generates an age key with `600` permissions for the private part and `644`
permissions for the public part.

- Type: `age`
- Arguments:
  - `private` (`path`): Path where to save the private part.
  - `public` (`path`): Path where to save the public part.
  - `renew` (`boolean`, `= false`): Whether to renew the key upon subsequent
    generations.

## SSH key

Generates an SSH key with `600` permissions for the private part and `644`
permissions for the public part.

- Type: `ssh-keygen`
- Arguments:
  - `name` (`string`): Name (comment) of the SSH key.
  - `private` (`path`): Path where to save the private part.
  - `public` (`path`): Path where to save the public part.
  - `renew` (`boolean`, `= false`): Whether to renew the key upon subsequent
    generations.

## OpenSSL CA

Generates a self-signed OpenSSL CA with `600` permissions for the private part
and `644` permissions for the public part.

- Type: `openssl-ca`
- Arguments:
  - `name` (`string`): Name (subject) of the CA.
  - `private` (`path`): Path where to save the private part.
  - `public` (`path`): Path where to save the public part.
  - `days` (`number`, `> 0`): For how many days will the CA be valid.
  - `renew` (`boolean`, `= false`): Whether to renew the CA upon subsequent
    generations.

## OpenSSL certificate

Generates an OpenSSL certificate with `600` permissions for the private part and
`644` permissions for the public part.

- Type: `openssl`
- Arguments:
  - `ca_private` (`path`): Path to the OpenSSL CA private part.
  - `ca_public` (`path`): Path to the OpenSSL CA public part.
  - `serial` (`path`): Where to save the serial number.
  - `name` (`string`): Name (subject) of the certificate.
  - `private` (`path`): Path where to save the private part.
  - `public` (`path`): Path where to save the public part.
  - `days` (`number`, `> 0`): For how many days will the certificate be valid.
  - `renew` (`boolean`, `= false`): Whether to renew the certificate upon
    subsequent generations.

## Nebula CA

Generates a self-signed Nebula CA with `600` permissions for the private part
and `644` permissions for the public part.

- Type: `nebula-ca`
- Arguments:
  - `name` (`string`): Name (subject) of the CA.
  - `private` (`path`): Path where to save the private part.
  - `public` (`path`): Path where to save the public part.
  - `days` (`number`, `> 0`): For how many days will the CA be valid.
  - `renew` (`boolean`, `= false`): Whether to renew the CA upon subsequent
    generations.

## Nebula certificate

Generates an Nebula certificate with `600` permissions for the private part and
`644` permissions for the public part.

- Type: `nebula`
- Arguments:
  - `ca_private` (`path`): Path to the Nebula CA private part.
  - `ca_public` (`path`): Path to the Nebula CA public part.
  - `name` (`string`): Name (subject) of the certificate.
  - `ip` (`string`): Certificate IP in CIDR form (ie. 10.8.0.1/24).
  - `private` (`path`): Path where to save the private part.
  - `public` (`path`): Path where to save the public part.
  - `renew` (`boolean`, `= false`): Whether to renew the certificate upon
    subsequent generations.

## Cockroachdb CA

Generates a self-signed Cockroachdb CA with `600` permissions for the private
part and `644` permissions for the public part.

- Type: `cockroach-ca`
- Arguments:
  - `private` (`path`): Path where to save the private part.
  - `public` (`path`): Path where to save the public part.
  - `renew` (`boolean`, `= false`): Whether to renew the CA upon subsequent
    generations.

## Cockroachdb node certificate

Generates an Cockroachdb node certificate with `600` permissions for the private
part and `644` permissions for the public part.

- Type: `cockroach`
- Arguments:
  - `ca_private` (`path`): Path to the Cockroachdb CA private part.
  - `ca_public` (`path`): Path to the Cockroachdb CA public part.
  - `hosts` (`array of string`): Cockroach node IP/DNS names.
  - `private` (`path`): Path where to save the private part.
  - `public` (`path`): Path where to save the public part.
  - `renew` (`boolean`, `= false`): Whether to renew the certificate upon
    subsequent generations.

## Cockroachdb client certificate

Generates an Cockroachdb client certificate with `600` permissions for the
private part and `644` permissions for the public part.

- Type: `cockroach-client`
- Arguments:
  - `ca_private` (`path`): Path to the Cockroachdb CA private part.
  - `ca_public` (`path`): Path to the Cockroachdb CA public part.
  - `private` (`path`): Path where to save the private part.
  - `public` (`path`): Path where to save the public part.
  - `user` (`string`): CockroachDB user name.
  - `renew` (`boolean`, `= false`): Whether to renew the certificate upon
    subsequent generations.

## Env

Generates an environment file with `600` permissions.

- Type: `env`
- Arguments:
  - `name` (`path`): Where to save the environment file.
  - `variables` (`object`): Variables to load in the environment file. Each
    variable value is the name of the file which will be opened, escaped, quoted
    and put into the environment variable. If the file is not present, the
    literal value of the variable will be escaped and quoted before being put
    into the environment variable.
  - `renew` (`boolean`, `= false`): Whether to renew the environment file upon
    subsequent generations.

## Moustache

Generates a file based on a Moustache template with `600` permissions.

- Type: `moustache`
- Arguments:
  - `name` (`path`): Where to save the generated file.
  - `variables` (`object`): Variables to load for inlining in the generated
    file. Each variable value is the name of the file which will be opened to be
    available in the moustache template. If the file is not present, the literal
    value of the variable will made available in the moustache template.
  - `template` (`string`): The Moustache template.
  - `renew` (`boolean`, `= false`): Whether to renew the generated file upon
    subsequent generations.

## SOPS

Generate a YAML SOPS secrets file with `600` permissions and encrypt it via an
age key to a file with `644` permissions.

- Type: `sops`
- Arguments:
  - `age` (`path`): Path to the age key to use for encryption.
  - `private` (`path`): Path where the plaintext secrets will be stored.
  - `public` (`path`): Path where the encrypted secrets will be stored.
  - `secrets` (`object`): Secrets to store. The secret values are paths to files
    which will be opened and put in the secrets. If the file is not present, the
    literal value of the secret will be escaped and quoted before being put into
    the secrets.
  - `renew` (`boolean`, `= false`): Whether to renew the SOPS file upon
    subsequent generations.
