{ lib, pkgs, ... }:

{
  integrate.nixpkgs.config = {
    allowUnfree = true;
  };

  seal.defaults.devShell = "dev";
  integrate.devShell.devShell = pkgs.mkShell {
    VAULT_ADDR = "http://127.0.0.1:8200";
    VAULT_TOKEN = "root";

    packages = with pkgs; [
      # version control
      git

      # scripts
      nushell
      just

      # nix
      nil
      nixpkgs-fmt
      nixVersions.stable

      # markdown
      markdownlint-cli
      nodePackages.markdown-link-check

      # documentation
      simple-http-server
      mdbook

      # spelling
      nodePackages.cspell

      # vault
      pueue
      vault

      # tools
      gum
      delta
      nlohmann_json_schema_validator
      age
      sops
      nebula
      openssl
      mkpasswd
      mo
      openssh
      vault-medusa

      # misc
      vscode-langservers-extracted
      nodePackages.prettier
      nodePackages.yaml-language-server
      taplo
    ] ++ (lib.optionals pkgs.hostPlatform.is64bit [
      marksman
    ]);
  };
}
