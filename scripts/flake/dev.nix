{ self, pkgs, ... }:

let
  buildInputs = self.lib.rumor.mkBuildInputs pkgs;
in
{
  integrate.nixpkgs.config = {
    allowUnfree = true;
  };

  seal.defaults.devShell = "dev";
  integrate.devShell.devShell = pkgs.mkShell {
    VAULT_DEV_ADDR = "127.0.0.1:8202";
    VAULT_ADDR = "http://127.0.0.1:8202";
    VAULT_TOKEN = "root";

    inputsFrom = [
      (self.lib.shells.mkShell pkgs)
      (self.lib.shells.mkToolShell pkgs)
      (self.lib.shells.mkTestShell pkgs)
    ];

    inherit buildInputs;

    packages = with pkgs; [
      mdbook
    ];
  };
}
