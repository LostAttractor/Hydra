{ config, ...}:
{
  nix.extraOptions = ''
    !include ${config.sops.templates."nix-access-tokens".path}
  '';

  sops.templates."nix-access-tokens" = {
    content = ''
      access-tokens = github.com=${config.sops.placeholder."nix/access-tokens/github"}
    '';
    # 目前我还不使用 wheel 组, 不过如果这会导致问题的话, 或许也可以给 hydra user 加到 wheel 组里?
    group = "hydra";
    mode = "0440";
  };

  sops.secrets."nix/access-tokens/github" = {};
}