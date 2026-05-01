{ pkgs, nodejs }:
let
  src = ./.;
in
pkgs.buildNpmPackage {
  pname = "twist-frontend";
  version = "0.1.0";
  inherit src;

  npmDeps = pkgs.fetchNpmDeps {
    inherit src;
    hash = "sha256-wNzBsjJOrECI3REYIfDSPdMvWxwIBXosjJVTicsRpWw=";
  };

  npmBuildScript = "build";

  postInstall = ''  
    mkdir -p $out/static  
    cp -r dist/* $out/static/  
  '';

  passthru.staticPath = "${placeholder "out"}/static";
}
