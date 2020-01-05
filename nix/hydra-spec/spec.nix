{ nixpkgs, declInput }:
let pkgs = import nixpkgs {};
    common = {
        enabled = 1;
        hidden = false;
        nixexprinput = "btrfs-backup-sync";
        checkinterval = 600;
        schedulingshares = 100;
        enableemail = false;
        emailoverride = "spencerjanssen@gmail.com";
        keepnr = 3;
    };
    unpinnedSources = (import ../niv-utils.nix { sourcePath = ../sources.json; }).hydraInputs;

    jobs = {
        btrfs-backup-sync = common // {
            nixexprpath = "default.nix";
            description = "btrfs-backup-sync with pinned dependencies";
            inputs = {
                btrfs-backup-sync = {
                    type = "git";
                    value = "git://github.com/spencerjanssen/btrfs-backup-sync.git";
                    emailresponsible = false;
                };
            };
        };
        btrfs-backup-sync-unpinned = common // {
            nixexprpath = "nix/ci.nix";
            description = "btrfs-backup-sync with latest dependencies";
            inputs = unpinnedSources // {
                btrfs-backup-sync = {
                    type = "git";
                    value = "git://github.com/spencerjanssen/btrfs-backup-sync.git";
                    emailresponsible = false;
                };
            };
        };
    };
    json = pkgs.writeTextFile {
        name = "spec.json";
        text = builtins.toJSON jobs;
    };
in {
    jobsets = json;
}