{ pkgs, config, ... }:
{
  # Nix-Serve
  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;
    secretKeyFile = config.sops.secrets."nix-serve/privkey".path;
  };

  services.nginx.virtualHosts."binarycache.home.lostattractor.net" = {
    locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
    locations."/".extraConfig = "zstd_types application/x-nix-archive;";
    addSSL = true;
    enableACME = true;
  };

  sops.secrets."nix-serve/privkey" = {};
  # pubkey: binarycache.home.lostattractor.net:nB258qoytYrdCe2pcI6qJ/M9R0l7Q5l9Bu5ryCbzItc=
}