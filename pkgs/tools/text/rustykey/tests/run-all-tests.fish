#!/usr/bin/env fish
    nix-build -I nixpkgs=/var/src/nixpkgs  ./rustykey.nix -A driverInteractive
and ./result/bin/nixos-test-driver --no-interactive
# echo running from rustykey-touch
and nix-build -I nixpkgs=/var/src/nixpkgs  ./rustykey-touch.nix -A driverInteractive
and ./result/bin/nixos-test-driver --no-interactive
# echo running from rustykey-1fa
and nix-build -I nixpkgs=/var/src/nixpkgs  ./rustykey-1fa.nix -A driverInteractive
and ./result/bin/nixos-test-driver --no-interactive
