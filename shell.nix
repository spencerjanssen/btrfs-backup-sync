{ }:
let hsPkgs = import ./nix/package-set.nix {};
in hsPkgs.shellFor {
    packages = ps: with ps; [
        btrfs-backup-sync
    ];

    withHoogle = true;

    exactDeps = true;
}
