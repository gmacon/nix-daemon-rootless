# Run nix-daemon as a non-root user

-   Run the VM by running

        nix run .#nixosConfigurations.vm.config.system.build.vm
    
-   Log in as user `a` with password `a`.
-   Try to use `nix` to do something.
-   Watch oom-killer kill everything as nix-daemon fork-bombs itself.
