{ pkgs, ... }:

{
  integrate.nixpkgs.config = {
    allowUnfree = true;
  };

  integrate.devShell.devShell = pkgs.mkShell {
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
      nodePackages.prettier
    ];
  };
}
