{
  outputs =
    { self, nixpkgs }:
    {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            system.stateVersion = "24.11";

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
              };
            };

            systemd.tmpfiles.rules = [
              "d /nix/var/nix/daemon-socket 0755 nix root - -"
            ];

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
        ];
      };
    };
}
