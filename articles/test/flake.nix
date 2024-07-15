{
  description = "Flaking callPackage";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs }: flake-parts.lib.mkFlake {inherit inputs;} {
    systems = ["x86_64-darwin"];
    perSystem = {self', config, pkgs, ...} : {
      packages.hello = pkgs.writeShellScriptBin "hello" ''
        echo "Hello, world!";
        ''; # (import hello.nix) {writeShellScriptBin = nixpkgs.pkgs.writeShellScriptBin;};
      packages.default = self'.packages.hello;
    }; 
  };
}