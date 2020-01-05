{ }:
let inherit (import ./nix/package-set.nix {}) hsPkgs nivPkgs;
in hsPkgs.shellFor {
    packages = ps: with ps; [
        btrfs-backup-sync
    ];

    withHoogle = true;

    exactDeps = true;

    buildInputs = [
        nivPkgs.niv
    ];
}
