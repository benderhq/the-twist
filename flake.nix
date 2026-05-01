{
  description = "Nix system flake for The Twist, a wireless guitar amplifier augmentation platform.";


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  };

  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [ "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI=" ];
  };

  outputs = { self, nixpkgs, nixos-raspberrypi }: {
    nixpkgs.config.doCheck = false;
    nixosConfigurations.rpi-app = nixos-raspberrypi.lib.nixosInstaller {
      specialArgs = { nixos-raspberrypi = nixos-raspberrypi; };
      modules = [
        {
          imports = with nixos-raspberrypi.nixosModules; [
            raspberry-pi-02.base
            raspberry-pi-02.bluetooth
            usb-gadget-ethernet
          ];
        }
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              twist-frontend = final.callPackage ./frontend { };
              twist-backend = final.callPackage ./backend { };
            })
          ];

          environment.systemPackages = with pkgs; [
            twist-backend
            twist-frontend
          ];

          users.users.twistapi = {
            isSystemUser = true;
            group = "twistapi";
          };

          users.groups.twistapi = { };

          systemd.services.the-twist-api = {
            description = "Twist backend";
            wantedBy = [ "multi-user.target" ];
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            environment = {
              STATIC_PATH = "${pkgs.twist-frontend}/static";
            };

            serviceConfig = {
              ExecStart = "${pkgs.twist-backend}/bin/twist-backend";
              Restart = "always";
              RestartSec = 2;

              User = "twistapi";
              Group = "twistapi";

              NoNewPrivileges = true;
              PrivateTmp = true;
              ProtectSystem = "strict";
              ProtectHome = true;
              StateDirectory = "the-twist-api";
              StateDirectoryMode = "0755";

              Environment = "PYTHONUNBUFFERED=1";
            };
            environment = {
              DATA_DIR = "/var/lib/the-twist-api";
            };
          };


          services.openssh = {
            enable = true;

            settings = {
              PasswordAuthentication = true;
              PermitRootLogin = "yes";
              KbdInteractiveAuthentication = true;
            };
          };

          users.users.root = {
            initialPassword = "bendernotfender";
          };

          users.users.nixos = {
            isNormalUser = true;
            initialPassword = "bendernotfender";
            extraGroups = [ "wheel" "networkmanager" ];
          };

          systemd.tmpfiles.rules = [
            "d /var/lib/the-twist-api 0755 the-twist-api the-twist-api -"
          ];

          security.sudo.wheelNeedsPassword = false;

          networking = {
            hostName = "rpi02w";
            firewall.allowedTCPPorts = [ 8000 ];
            networkmanager = {
              enable = true;

              ensureProfiles.profiles = {
                "my-wifi" = {
                  connection = {
                    id = "my-wifi";
                    interface-name = "wlan0";
                    type = "wifi";
                  };

                  wifi = {
                    mode = "infrastructure";
                    ssid = "this_wifi_name_is_meta";
                  };

                  wifi-security = {
                    key-mgmt = "wpa-psk";
                    psk = "this_wifi_password_is_super_insecure_so_i_pray_this_isnt_your_password_otherwise_you_should_change_it";
                  };

                  ipv4.method = "auto";
                  ipv6.method = "auto";
                };
                "my-ap" = {
                  connection = {
                    id = "my-ap";
                    interface-name = "wlan0";
                    type = "wifi";
                    autoconnect = true;
                  };
                  wifi = {
                    mode = "ap";
                    ssid = "MyRPI-AP";
                  };
                  wifi-security = {
                    key-mgmt = "wpa-psk";
                    psk = "apPassword123";
                  };
                  ipv4.method = "shared";
                  ipv6.method = "ignore";
                };
              };
            };
          };


        })
      ];
    };

    installerImages.rpi02 = self.nixosConfigurations.rpi-app.config.system.build.sdImage;
  };
}
