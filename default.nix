let inherit (import ./nix/package-set.nix { }) hsPkgs shell;
in
{
  inherit shell;
  btrfs-backup-sync = hsPkgs.btrfs-backup-sync.components.exes.btrfs-backup-sync;
}
