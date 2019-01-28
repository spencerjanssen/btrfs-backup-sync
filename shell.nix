{ }:
let nixpkgs = import <nixpkgs> { };
    btrfs-backup-sync = nixpkgs.haskellPackages.developPackage {
        root = ./.;
    };
in btrfs-backup-sync