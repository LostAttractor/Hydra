{ pkgs, inputs, config, ... }:

{
  imports = [
    (inputs.homelab + "/features/basic.nix")
    (inputs.homelab + "/features/fish.nix")
    (import (inputs.homelab + "/features/telemetry") ({ inherit config; promtail_password_file = config.sops.secrets.promtail.path; }))
    ./features/binfmt.nix
  ];

  ### OOM configuration
  # Create a separate slice for nix-daemon that is
  # memory-managed by the userspace systemd-oomd killer
  systemd.slices."nix-daemon".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "60%";
  };
  systemd.services."nix-daemon".serviceConfig = {
    Slice = "nix-daemon.slice";
    # If a kernel-level OOM event does occur anyway,
    # strongly prefer killing nix-daemon child processes
    # OOMScoreAdjust = 1000;
  };

  users = {
    # Don't allow mutation of users outside of the config.
    mutableUsers = false;
    # Privilege User
    users.root.openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBC5HypvbsI4xvwfd4Uw7D+SV0AevYPS/nCarFwfBwrMHKybbqUJV1cLM1ySZPxXcZD7+3m48Riiwlssh6o7WM/M= openpgp:0xDE4C24F6" ];
    # Unprivilege User
    users.nixremote = {
      isSystemUser = true;
      shell = pkgs.bash;
      group = "nixremote";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNa3pXg7jRt/0MTKoflN6fhh9NDNdQaY62tbUEcWWXA nixremote" ];
    };
    groups.nixremote = {};
  };

  # Unprivilege User
  nix.settings.trusted-users = [ "nixremote" ];

  boot.tmp.cleanOnBoot = true;

  sops.secrets.promtail = {
    sopsFile = ../secrets/promtail.yaml;
    owner = "promtail";
  };

  system.stateVersion = "24.05";
}