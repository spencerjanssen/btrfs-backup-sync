{}:
let nixpkgs = import <nixpkgs> { };
in
{
    btrfs-backup-sync = nixpkgs.haskellPackages.callPackage ./btrfs-backup-sync.nix { };
}