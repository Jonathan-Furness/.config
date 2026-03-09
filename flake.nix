{
  description = "Dotfiles managed with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in {
      homeConfigurations = builtins.listToAttrs (map (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          username = builtins.getEnv "USER";
          homeDir = builtins.getEnv "HOME";
        in {
          name = "${system}";
          value = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./home.nix ];
            extraSpecialArgs = {
              inherit username homeDir;
            };
          };
        }
      ) [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]);
    };
}
