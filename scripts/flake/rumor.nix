{ self, pkgs, lib, ... }:

let
  buildInputs = with pkgs; [
    nushell
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
    coreutils
  ] ++ (lib.optionals pkgs.hostPlatform.isLinux [
    cockroachdb
  ]);

  shebang =
    ''#!${pkgs.nushell}/bin/nu --stdin''
    + ''\n$env.PATH = "${lib.makeBinPath buildInputs}"'';
in
{
  integrate.nixpkgs.config = {
    allowUnfree = true;
  };

  seal.defaults.package = "rumor";
  integrate.package.package = pkgs.stdenvNoCC.mkDerivation {
    pname = "rumor";
    version = "1.0.0";

    src = self;

    inherit buildInputs;

    patchPhase = ''
      runHook prePatch

      sed \
        -i 's|#!/usr/bin/env -S nu --stdin|${shebang}|g' \
        ./src/main.nu

      sed \
        -i 's|\$"(\$env.FILE_PWD)/schema.json"'"|\"$out/share/rumor/schema.json\"|g" \
        ./src/main.nu
      sed \
        -i 's|\$"(\$env.FILE_PWD)/main.nu"'"|\"$out/bin/rumor\"|g" \
        ./src/main.nu

      runHook postPatch
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/rumor
      cp ./src/schema.json $out/share/rumor

      mkdir -p $out/bin
      cp ./src/main.nu $out/bin/rumor
      chmod +x $out/bin/rumor

      runHook postInstall
    '';

    meta = {
      description = "A small tool for generating, encrypting, and managing secrets";
      mainProgram = "rumor";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  };
}
