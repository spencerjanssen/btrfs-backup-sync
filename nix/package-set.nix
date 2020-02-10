{ sources ? import ./sources.nix
, haskellCompiler ? "ghc865"
}:
let pkgs = import sources.nixpkgs (import sources."haskell.nix");
    nixIgnores = [
      "*.nix"
      "nix/"
      ".github/"
    ];
    hsPkgs = pkgs.haskell-nix.cabalProject {
      src = pkgs.nix-gitignore.gitignoreSource nixIgnores ../.;
      ghc = pkgs.buildPackages.pkgs.haskell-nix.compiler.${haskellCompiler};
      name = "btrfs-backup-sync";
    };
    nivPkgs = (import sources.niv {});
    hies = (import sources.all-hies {}).selection {
      selector = p: {
        ${haskellCompiler} = p.${haskellCompiler};
      };
    };
    shell = hsPkgs.shellFor {
      packages = ps: with ps; [
        btrfs-backup-sync
      ];
      withHoogle = true;
      exactDeps = true;
      buildInputs = [
        nivPkgs.niv
        hies
      ];
    };
in
{
  inherit hsPkgs pkgs nivPkgs hies shell;
}
