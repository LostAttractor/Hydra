{
  description = "ChaosAttractor's Hydra & Nixbuilder Server Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    homelab.url = "github:lostattractor/homelab";
    homelab.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, deploy-rs, ... } @ inputs : rec {
    # Hydra@PVE2.home.lostattractor.net
    nixosConfigurations."hydra@pve2.home.lostattractor.net" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration/hydra
        (inputs.homelab + "/hardware/lxc")
        { networking.hostName = "hydra"; }
        inputs.sops-nix.nixosModules.sops
      ];
    };
    # NixBuilder@PVE.home.lostattractor.net
    nixosConfigurations."nixbuilder@pve.home.lostattractor.net" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration/nixbuilder
        (inputs.homelab + "/hardware/lxc")
        { networking.hostName = "nixbuilder1"; }
        inputs.sops-nix.nixosModules.sops
      ];
    };

    # Deploy-RS Configuration
    deploy = {
      sshUser = "root";
      magicRollback = false;

      nodes."hydra@pve2.home.lostattractor.net" = {
        hostname = "hydra.home.lostattractor.net";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations."hydra@pve2.home.lostattractor.net";
      };
      nodes."nixbuilder@pve.home.lostattractor.net" = {
        hostname = "nixbuilder1.home.lostattractor.net";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations."nixbuilder@pve.home.lostattractor.net";
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (_system: deployLib: deployLib.deployChecks deploy) deploy-rs.lib;

    hydraJobs = with nixpkgs.lib; {
      nixosConfigurations = mapAttrs' (name: config:
        nameValuePair name config.config.system.build.toplevel)
        nixosConfigurations;
    };
  };
}
