{pkgs ? import <nixpkgs> { }}:
let btrfs-backup-sync = pkgs.haskellPackages.callCabal2nix "btrfs-backup-sync" ./. {};
in
{
    inherit btrfs-backup-sync;
}