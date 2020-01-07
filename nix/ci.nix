let sources = {
      all-hies = <all-hies>;
      "haskell.nix" = <haskell.nix>;
      niv = <niv>;
      nixpkgs = <nixpkgs>;

    };
    ps = import ./package-set.nix { inherit sources; };
in
{
  inherit (ps) shell;
  btrfs-backup-sync = ps.hsPkgs.btrfs-backup-sync.components.exes.btrfs-backup-sync;
}
