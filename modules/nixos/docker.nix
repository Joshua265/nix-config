{
  pkgs,
  config,
  ...
}: {
  virtualisation.docker.enable = true;

  users.users.user.extraGroups = ["docker"];
}
