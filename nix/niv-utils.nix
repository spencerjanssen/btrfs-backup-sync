{ sourcePath }:
let pkgs = import <nixpkgs> {};
    toInput = name: value: {
      type = "git";
      value = "git://github.com/${value.owner}/${value.repo}.git ${value.branch}";
      emailresponsible = false;
    };
    mka = s:
      let split = pkgs.lib.strings.splitString "=" s;
      in if builtins.length split == 2
          then { "${builtins.head split}" = builtins.head (builtins.tail split); }
          else {}; 
in rec {
  parsedSource = builtins.fromJSON (builtins.readFile sourcePath);
  hydraInputs = pkgs.lib.attrsets.mapAttrs toInput parsedSource;
  sourcesFromNixPath = builtins.foldl' (a: b: a // b) {} (map mka (pkgs.lib.strings.splitString ":" (builtins.getEnv "NIX_PATH")));
}