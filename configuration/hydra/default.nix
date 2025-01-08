{ inputs, ... }:

{
  imports = [
    (inputs.homelab + "/features/nix/minimal.nix")
    ../features/binfmt.nix
    ./features/builders.nix
    ./features/hydra.nix
    ./features/harmonia.nix
    (inputs.homelab + "/features/nginx.nix")
    ./secrets/nix/access-tokens.nix
  ];

  nix.settings.keep-going = true;

  # Auto Clean
  nix.settings.min-free = "${toString (40 * 1024 * 1024 * 1024)}";
  nix.settings.max-free = "${toString (60 * 1024 * 1024 * 1024)}";

  sops.defaultSopsFile = ../../secrets/hydra.yaml;

  system.stateVersion = "24.05";
}