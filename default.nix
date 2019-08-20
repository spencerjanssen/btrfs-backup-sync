{nixpkgs ? import <nixpkgs> { }}:
let btrfs-backup-sync = nixpkgs.haskellPackages.callCabal2nix "btrfs-backup-sync" ./. {};
in
{
    inherit btrfs-backup-sync;
}