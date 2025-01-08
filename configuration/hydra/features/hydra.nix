{ config, ... }:
{
  # Allowed URIs
  # TODO: https://nixos.org/manual/nix/stable/release-notes/rl-2.20
  nix.settings.allowed-uris = [ "github:" "gitlab:" "https:" ];

  # Hydra
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.lostattractor.net";
    useSubstitutes = true;
    notificationSender = "Hydra <root@lostattractor.net>";
    smtpHost = "smtp.gmail.com";
    extraConfig = ''
      email_notification = 1
      max_output_size = 34359738367 # 1024^3 * 32 - 1

      queue_runner_metrics_address = [::]:9198
      <hydra_notify>
        <prometheus>
          listen_address = 0.0.0.0
          port = 9199
        </prometheus>
      </hydra_notify>
    '';
  };

  networking.firewall.allowedTCPPorts = [ 9198 9199 ];

  systemd.services.hydra-notify = {
    serviceConfig.EnvironmentFile = config.sops.secrets."email".path;
  };

  services.nginx.virtualHosts."hydra.lostattractor.net" = {
    locations."/".proxyPass = "http://localhost:${toString config.services.hydra.port}";
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "hydra.home.lostattractor.net" ];
  };

  sops.secrets."email" = {};
}
