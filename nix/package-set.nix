{ sources ? import ./sources.nix
, haskellCompiler ? "ghc865"
}:
let pkgs = import sources.nixpkgs (import sources."haskell.nix");
    hsPkgs = pkgs.haskell-nix.cabalProject {
      src = pkgs.nix-gitignore.gitignoreSource [] ../.;
      ghc = pkgs.buildPackages.pkgs.haskell-nix.compiler.${haskellCompiler};
    };
    nivPkgs = (import sources.niv {});
    hies = (import sources.all-hies {}).bios.selection {
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
