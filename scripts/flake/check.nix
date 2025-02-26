{ pkgs, ... }:

{
  integrate.nixpkgs.config = {
    allowUnfree = true;
  };

  integrate.devShell.devShell = pkgs.mkShell {
    VAULT_ADDR = "http://127.0.0.1:8200";
    VAULT_TOKEN = "root";

    packages = with pkgs; [
      # version control
      git

      # scripts
      just
      nushell

      # spelling
      nodePackages.cspell

      # nix
      nixpkgs-fmt

      # markdown
      markdownlint-cli
      nodePackages.markdown-link-check

      # tools
      pueue
      gum
      delta
      fd
      coreutils

      # inputs
      nlohmann_json_schema_validator
      age
      sops
      nebula
      openssl
      mkpasswd
      mo
      openssh
      vault
      vault-medusa

      # misc
      nodePackages.prettier
    ];
  };
}
