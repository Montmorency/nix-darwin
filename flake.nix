{
  description = "Montmorency Darwin System Flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  # options:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
          pkgs.emacs
          pkgs.ihp-new
          pkgs.direnv
        ];

      environment.variables = {
                                 EDITOR = "vim";
                              };    

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      nix.settings.trusted-users = ["root" "lambert" "admin"];   
      nix.settings.extra-trusted-users = ["root" "lambert" "admin"];   
      nix.settings.trusted-substituters = ["https://cache.nixos.org" "https://cache.nixos.org/" "https://montmorency-packages.cachix.org" "https://digitallyinduced.cachix.org"];
  

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      launchd.daemons.linux-builder = { serviceConfig = { StandardOutPath = "/var/log/darwin-builder.log"; StandardErrorPath = "/var/log/darwin-builder.log"; }; };
      nix.linux-builder.enable = true;
      nix.linux-builder.ephemeral = false;
      nix.linux-builder.config = { 
       nix.settings.sandbox = false; 
       services.openssh.enable = true;
      };
      nix.linux-builder.maxJobs = 4;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."Enrico" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Enrico".pkgs;
  };
}
