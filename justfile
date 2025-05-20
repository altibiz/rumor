set windows-shell := ["nu.exe", "-c"]
set shell := ["nu", "-c"]

root := absolute_path('')

default:
    @just --choose

format:
    cd '{{ root }}'; just --unstable --fmt
    prettier --write '{{ root }}'
    nixpkgs-fmt '{{ root }}'

lint:
    cd '{{ root }}'; just --unstable --fmt --check
    prettier --check '{{ root }}'
    cspell lint '{{ root }}' --no-progress
    nixpkgs-fmt --check '{{ root }}'
    markdownlint '{{ root }}'
    markdown-link-check \
      --config .markdown-link-check.json \
      --quiet \
      ...(fd '.*.md' | lines)
    nix flake check --all-systems
    @just test-all

upgrade:
    nix flake update

test-clean *args:
    nu -c '{{ root }}/scripts/test.nu stop {{ args }}'

test-all *args:
    nu -c '{{ root }}/scripts/test.nu all "{{ root }}" {{ args }}'

test-one test *args:
    nu -c '{{ root }}/scripts/test.nu one "{{ root }}" "{{ test }}" {{ args }}'

docs:
    rm -rf '{{ root }}/artifacts'
    cd '{{ root }}/docs'; mdbook build
    mv '{{ root }}/docs/book' '{{ root }}/artifacts'
