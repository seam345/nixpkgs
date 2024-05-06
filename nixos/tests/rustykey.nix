# NixOS test for rustykey FDE
#
# todo move out of nixos/test while it cant be ran automaticaly coping pkgs/os-specific/linux/usbrelay/test.nix
# It is not stored in nixos/tests directory, because it requires the
# yubikey connected to the host computer and as such, it cannot be
# run automatically.
#
# Run this test as:
#
#     nix-build  ./nixos/tests/rustykey.nix -A driverInteractive && ./result/bin/nixos-test-driver --no-interactive
#
# The interactive driver is required because the default
# (non-interactive) driver uses qemu without support for passing USB
# devices to the guest (see
# https://discourse.nixos.org/t/hardware-dependent-nixos-tests/18564
# for discussion of other alternatives).

import ./make-test-python.nix ({ lib, pkgs, ... }: {
  name = "rustykey";

  nodes.machine = { pkgs, ... }: {
    # Use systemd-boot
    virtualisation = {
      emptyDiskImages = [ 512 512 ];
      useBootLoader = true;
      useEFIBoot = true;
      qemu.options = ["-device usb-host,vendorid=0x1050,productid=0x0407"];
      # To boot off the encrypted disk, we need to have a init script which comes from the Nix store
      mountHostNixStore = true;
    };
    boot.loader.systemd-boot.enable = true;

    environment.systemPackages = with pkgs; [ cryptsetup rustykey ];

    specialisation.boot-luks.configuration = {
      boot.initrd.luks.yubikeySupport = true;
      boot.initrd.luks.devices = lib.mkVMOverride {
        cryptroot = {
          /*preOpenCommands = ''
            wait_yubikey() {
              return 0
            }
          '';*/
          device = "/dev/vdb";
           yubikey = {
              slot = 1;
              twoFactor = true;
              debug = true;
              storage = {
                device = "/dev/vdc";
                fsType = "ext4";
              };
            };
#          keyFile = "/etc/cryptroot.key";
        };
      };
      virtualisation.rootDevice = "/dev/mapper/cryptroot";
#      boot.initrd.secrets."/etc/cryptroot.key" = keyfile;
    };
  };

  testScript = ''
    # Create encrypted volume
    machine.wait_for_unit("multi-user.target")
    machine.succeed(
      "mkfs.ext4 /dev/vdc",
      "mkdir /crypt-storage",
      "mount /dev/vdc /crypt-storage",
      "mkdir /crypt-storage/crypt-storage",
    )
    # format encrypted volume
    machine.succeed("echo -n supersecret |  rustykey format --cryptsetup cryptsetup --salt-iter-file /crypt-storage/crypt-storage/default --yubikey-slot 1  --device /dev/vdb --password-file=- -- --iter-time=1")

    # Boot from the encrypted disk
    machine.succeed("bootctl set-default nixos-generation-1-specialisation-boot-luks.conf")
    machine.succeed("sync")
    machine.crash()
    machine.start()

    # Boot and decrypt the disk
    machine.wait_for_console_text("Asking user for password") # Matching on a log message as I couldn't match on the password promt, I think because it was implementing it's own console for prompt
    machine.send_console("supersecret\x0D") # unsure why \n didnt work but \x0D does
    machine.wait_for_unit("multi-user.target")
    assert "/dev/mapper/cryptroot on / type ext4" in machine.succeed("mount"), "/dev/mapper/cryptroot do not appear in mountpoints list"
  '';
})
