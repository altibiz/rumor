{ self, pkgs, ... }:

let
  buildInputs = self.lib.rumor.mkBuildInputs pkgs;
in
{
  integrate.nixpkgs.config = {
    allowUnfree = true;
  };

  integrate.devShell.devShell = pkgs.mkShell {
    VAULT_DEV_ADDR = "127.0.0.1:8202";
    VAULT_ADDR = "http://127.0.0.1:8202";
    VAULT_TOKEN = "root";

    inputsFrom = [
      (self.lib.shells.mkShell pkgs)
      (self.lib.shells.mkCiShell pkgs)
      (self.lib.shells.mkTestShell pkgs)
    ];

    inherit buildInputs;
  };
}
