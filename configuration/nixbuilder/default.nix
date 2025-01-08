{ inputs, ... }:

{
  imports = [
    (inputs.homelab + "/features/nix")
  ];

  # Substituters
  # nix.settings.substituters = [ "https://binarycache.home.lostattractor.net" ];

  # Auto Clean
  nix.settings.min-free = "${toString (15 * 1024 * 1024 * 1024)}";
  nix.settings.max-free = "${toString (30 * 1024 * 1024 * 1024)}";
}