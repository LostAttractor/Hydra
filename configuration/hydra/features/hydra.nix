{ config, ... }:
{
  # Allowed URIs
  # TODO: https://nixos.org/manual/nix/stable/release-notes/rl-2.20
  nix.settings.allowed-uris = [ "github:" "gitlab:" "https:" ];

  # Hydra
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.home.lostattractor.net";
    notificationSender = "hydra@lostattractor.net";
    useSubstitutes = true;
    extraConfig = ''
      max_output_size = 34359738367 # 1024^3 * 32 - 1
    '';
  };

  services.nginx.virtualHosts."hydra.home.lostattractor.net" = {
    locations."/".proxyPass = "http://localhost:${toString config.services.hydra.port}";
    forceSSL = true;
    enableACME = true;
  };
}
