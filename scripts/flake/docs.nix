{ self, pkgs, ... }:

{
  integrate.devShell.devShell = pkgs.mkShell {
    inputsFrom = [ (self.lib.shells.mkShell pkgs) ];

    packages = with pkgs; [
      mdbook
    ];
  };
}
