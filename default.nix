let hsPkgs = (import ./nix/package-set.nix { }).hsPkgs;
in
{
  btrfs-backup-sync = hsPkgs.btrfs-backup-sync.components.exes.btrfs-backup-sync;
}
