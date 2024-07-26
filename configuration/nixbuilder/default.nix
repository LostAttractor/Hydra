{ pkgs, inputs, ... }:

{
  imports = [
    (inputs.homelab + "/features/nix")
    (inputs.homelab + "/features/fish.nix")
    (inputs.homelab + "/features/telemetry")
    ../features/binfmt.nix
  ];

  # Substituters
  nix.settings.substituters = [ "https://binarycache.home.lostattractor.net" ];
  nix.settings.trusted-public-keys =  [ "binarycache.home.lostattractor.net:nB258qoytYrdCe2pcI6qJ/M9R0l7Q5l9Bu5ryCbzItc=" ];

  users = {
    # Don't allow mutation of users outside of the config.
    mutableUsers = false;
    # Privilege User
    users.root.openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBC5HypvbsI4xvwfd4Uw7D+SV0AevYPS/nCarFwfBwrMHKybbqUJV1cLM1ySZPxXcZD7+3m48Riiwlssh6o7WM/M= openpgp:0xDE4C24F6" ];
    # Unprivilege User
    users.nixremote = {
      isSystemUser = true;
      useDefaultShell = true;
      group = "nixremote";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNa3pXg7jRt/0MTKoflN6fhh9NDNdQaY62tbUEcWWXA nixremote" ];
    };
    groups.nixremote = {};
  };

  # Unprivilege User
  nix.settings.trusted-users = [ "root" "nixremote" ];

  # Auto Clean
  nix.settings.min-free = "${toString (15 * 1024 * 1024 * 1024)}";
  nix.settings.max-free = "${toString (30 * 1024 * 1024 * 1024)}";

  # Basic Packages
  environment.systemPackages = with pkgs; [ htop btop duf ];

  system.stateVersion = "24.05";
}