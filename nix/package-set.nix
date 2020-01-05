{ sources ? import ./sources.nix
, haskellCompiler ? "ghc865"
}:
let pkgs = import sources.nixpkgs (import sources."haskell.nix");
    hsPkgs = pkgs.haskell-nix.cabalProject {
      src = pkgs.nix-gitignore.gitignoreSource [] ../.;
      ghc = pkgs.buildPackages.pkgs.haskell-nix.compiler.${haskellCompiler};
    };
    nivPkgs = (import sources.niv {});
in
{
  inherit hsPkgs pkgs nivPkgs;
}
