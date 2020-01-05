let hsPkgs = import ./nix/package-set.nix { };
in
{
  btrfs-backup-sync = hsPkgs.btrfs-backup-sync.components.exes.btrfs-backup-sync;
}
