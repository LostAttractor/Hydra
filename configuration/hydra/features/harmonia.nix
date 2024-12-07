{ pkgs, config, ... }:
{
  # https://github.com/nix-community/harmonia
  services.harmonia = {
    enable = true;
    signKeyPaths = [ config.sops.secrets."nix-serve/privkey".path ];
  };

  services.nginx = {
    package = pkgs.nginxStable.override {
      modules = [ pkgs.nginxModules.zstd ];
    };
    virtualHosts."binarycache.lostattractor.net" = {
      locations."/".extraConfig = ''
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;

        zstd on;
        zstd_types application/x-nix-archive;
      '';
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "binarycache.home.lostattractor.net" ];
    };
  };

  sops.secrets."nix-serve/privkey" = {};
  # pubkey: binarycache.lostattractor.net:nB258qoytYrdCe2pcI6qJ/M9R0l7Q5l9Bu5ryCbzItc=
  # pubkey: binarycache.home.lostattractor.net:nB258qoytYrdCe2pcI6qJ/M9R0l7Q5l9Bu5ryCbzItc=
}