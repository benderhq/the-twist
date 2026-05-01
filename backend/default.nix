{ pkgs }:

let
  python = pkgs.python312;

  ltamp = python.pkgs.buildPythonPackage {
    pname = "ltamp";
    version = "0.2.7";

    src = ./ltamp;

    format = "pyproject";
    nativeBuildInputs = with python.pkgs; [
      setuptools
      wheel
    ];

    propagatedBuildInputs = with python.pkgs; [
      hidapi
      protobuf
    ];
  };

  pythonEnv = python.withPackages (ps: with ps; [
    hidapi
    protobuf
    fastapi
    uvicorn
    python-socketio
    aiofiles
    sqlmodel
    ltamp
  ]);
in
pkgs.writeShellApplication {
  name = "twist-backend";
  runtimeInputs = [ pythonEnv ];
  text = ''
    cd ${./.}
    exec uvicorn app:app \
      --host 0.0.0.0 \
      --port 8000
  '';
}


