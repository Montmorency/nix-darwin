{
  description = "Montmorency Darwin System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs,  ... }:
  # options:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        with pkgs; 
        [ vim
          devenv
          emacs
#          texliveSmall
          ihp-new
          direnv
          nixos-rebuild
          cachix
          git
          lsof
          nix-tree
        ];

      environment.variables = {
                                 EDITOR = "vim";
                              };    

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      nix.settings.trusted-users = ["root" "lambert" "admin" ];   
      nix.settings.extra-trusted-users = ["root" "lambert" "admin"];   
      nix.settings.trusted-substituters = ["https://cache.nixos.org/" "https://montmorency-packages.cachix.org" "https://digitallyinduced.cachix.org"];
  

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      programs.direnv.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      # https://github.com/LnL7/nix-darwin/pull/974 (issue for over riding host platform on builder)
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/profiles/macos-builder.nix
      nixpkgs.hostPlatform = "x86_64-darwin";
      #
      launchd.daemons.linux-builder = { 
        serviceConfig = { StandardOutPath = "/var/log/darwin-builder.log"; 
        StandardErrorPath = "/var/log/darwin-builder.log"; }; 
      };
      
       #https://github.com/LnL7/nix-darwin/blob/6ab87b7c84d4ee873e937108c4ff80c015a40c7a/modules/nix/linux-builder.nix
       nix.linux-builder.enable = true;
       nix.linux-builder.ephemeral= true;
       nix.linux-builder.package = pkgs.darwin.linux-builder-x86_64;
       #nix.linux-builder.maxJobs = 4;
       nix.linux-builder.workingDirectory="/var/lib/darwin-builder"; 
       nix.linux-builder.config = { 
          virtualisation.cores = 4;
          virtualisation.darwin-builder = {
            diskSize = 80 * 1024;
            memorySize = 16 * 1024;
          };
          nix.settings.trusted-users = ["root" "lambert" "admin" ];   
          nix.settings.trusted-substituters = ["https://cache.nixos.org" "https://cache.nixos.org/" "https://montmorency-packages.cachix.org" "https://digitallyinduced.cachix.org"];
          services.openssh.enable = true;
          nixpkgs.hostPlatform = "x86_64-linux";
          environment.systemPackages = [ pkgs.vim ];
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."Enrico" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
    ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Enrico".pkgs;
  };
}
