{ mkDerivation, base, containers, directory, filepath, process
, stdenv
}:
mkDerivation {
  pname = "btrfs-backup-sync";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base containers directory filepath process
  ];
  license = stdenv.lib.licenses.bsd3;
}
