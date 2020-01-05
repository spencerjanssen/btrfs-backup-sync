{ }:
let inherit (import ./nix/package-set.nix {}) hsPkgs nivPkgs hies;
in hsPkgs.shellFor {
    packages = ps: with ps; [
        btrfs-backup-sync
    ];

    withHoogle = true;

    exactDeps = true;

    buildInputs = [
        nivPkgs.niv
        hies
    ];
}
