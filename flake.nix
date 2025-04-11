{
  outputs =
    { self, nixpkgs }:
    {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            { config, pkgs, ... }:
            let
              preparePaths = pkgs.writeShellScript "prepare-paths" ''
                if [ "$(${pkgs.coreutils}/bin/stat --format %U /nix)" = "root" ]; then
                  ${pkgs.coreutils}/bin/chown --recursive nix /nix
                fi
              '';
            in
            {
              system.stateVersion = "24.11";

              boot.readOnlyNixStore = false;

              nix = {
                settings = {
                  experimental-features = [
                    "auto-allocate-uids"
                    "flakes"
                    "nix-command"
                  ];
                  auto-allocate-uids = true;
                };
              };

              systemd.services.nix-daemon = {
                serviceConfig = {
                  User = "nix";
                  AmbientCapabilities = "CAP_DAC_READ_SEARCH";
                  ExecStartPre = "+${preparePaths}";
                  ExecStart = [
                    ""
                    "@${config.nix.package}/bin/nix-daemon nix-daemon --daemon --store local"
                  ];
                  RuntimeDirectory = "nix-daemon";
                  StateDirectory = "nix-daemon";
                  CacheDirectory = "nix-daemon";
                  LogsDirectory = "nix-daemon";
                };
              };

              users.users.nix = {
                isSystemUser = true;
                group = "nixbld";
              };

              users.users.a = {
                isNormalUser = true;
                group = "wheel";
                password = "a";
              };

              security.sudo.enable = true;
            }
          )
        ];
      };
    };
}
