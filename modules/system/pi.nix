{ inputs, ... }:
{
  flake.systemConfigs.pi = inputs.system-manager.lib.makeSystemConfig {
    modules = [
      (
        { pkgs, lib, ... }:
        let
          greeter = pkgs.noctalia-greeter;
          pamSystemd = "${pkgs.systemd}/lib/security/pam_systemd.so";

          greeterConfig = (pkgs.formats.toml { }).generate "greeter.toml" {
            session.default = "Sway";
            user.default = "josh";
            cursor = {
              theme = "phinger-cursors-light";
              size = 32;
              path = "${pkgs.phinger-cursors}/share/icons";
            };
            keyboard = {
              layout = "us";
              variant = "";
            };
          };

          # greetd hands the session a minimal environment, so give sway the
          # same PATH/XDG_DATA_DIRS it would get from a normal login.
          # Pi 5 exposes the v3d render device and the vc4 display device as
          # separate DRM cards, and the card numbers can move between boots.
          # Find the vc4/HDMI card by its platform path instead of hardcoding.
          displayCard = ''
            for card in /sys/class/drm/card[0-9]; do
              if readlink -f "$card/device" 2>/dev/null | grep -q 'axi:gpu'; then
                echo "/dev/dri/$(basename "$card")"
                exit 0
              fi
            done
            echo /dev/dri/card1
          '';

          greeterSession = pkgs.writeShellScript "noctalia-greeter-session-pi" ''
            export XDG_DATA_DIRS=/run/system-manager/sw/share:/usr/local/share:/usr/share
            export __EGL_VENDOR_LIBRARY_DIRS=${pkgs.mesa}/share/glvnd/egl_vendor.d
            export LIBGL_DRIVERS_PATH=${pkgs.mesa}/lib/dri
            WLR_DRM_DEVICES="$(${displayCard})"
            export WLR_DRM_DEVICES
            exec ${greeter}/bin/noctalia-greeter-session "$@"
          '';

          swaySession = pkgs.writeShellScript "noctalia-sway-session" ''
            export PATH="$HOME/.nix-profile/bin:/run/system-manager/sw/bin:/usr/local/bin:/usr/bin:/bin"
            export XDG_DATA_DIRS="$HOME/.nix-profile/share:/run/system-manager/sw/share:/usr/local/share:/usr/share"
            WLR_DRM_DEVICES="$(${displayCard})"
            export WLR_DRM_DEVICES
            exec ${pkgs.swayfx}/bin/sway "$@"
          '';

          swayDesktop = pkgs.writeTextFile {
            name = "noctalia-sway-desktop";
            destination = "/share/wayland-sessions/sway.desktop";
            text = ''
              [Desktop Entry]
              Name=Sway
              Comment=An i3-compatible Wayland compositor
              Exec=${swaySession}
              Type=Application
              DesktopNames=sway;wlroots;swayfx
            '';
          };
        in
        {
          nixpkgs.hostPlatform = "aarch64-linux";

          environment.systemPackages = [
            pkgs.greetd
            greeter
            pkgs.mesa
            pkgs.phinger-cursors
            swayDesktop
          ];

          environment.pathsToLink = [
            "/bin"
            "/share/wayland-sessions"
          ];

          users.extraGroups.greeter = { };
          users.extraUsers.greeter = {
            isSystemUser = true;
            group = "greeter";
            home = "/var/lib/noctalia-greeter";
            createHome = false;
            shell = "/usr/sbin/nologin";
          };

          # The greeter compositor needs the same device access as a seat.
          systemd.services.greeter-groups = {
            description = "Add the greeter user to device access groups";
            wantedBy = [ "multi-user.target" ];
            after = [ "userborn.service" ];
            before = [ "greetd.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = "/usr/sbin/usermod -aG video,render,input greeter";
            };
          };

          systemd.services.greetd = {
            description = "greetd - a minimal and flexible login manager daemon";
            wantedBy = [ "multi-user.target" ];
            after = [
              "systemd-user-sessions.service"
              "userborn.service"
              "greeter-groups.service"
            ];
            wants = [ "systemd-user-sessions.service" ];
            requires = [
              "userborn.service"
              "greeter-groups.service"
            ];
            unitConfig = {
              Conflicts = [ "getty@tty1.service" ];
            };
            serviceConfig = {
              Type = "idle";
              ExecStart = "${pkgs.greetd}/bin/greetd --config /etc/greetd/config.toml";
              Restart = "on-success";
              IgnoreSIGPIPE = false;
              SendSIGHUP = true;
              TimeoutStopSec = "30s";
              KeyringMode = "shared";
            };
          };

          systemd.maskedUnits = [
            "lightdm.service"
            "sddm.service"
          ];

          systemd.tmpfiles.settings = {
            "10-noctalia-greeter" = {
              "/var/lib/noctalia-greeter".d = {
                user = "greeter";
                group = "greeter";
                mode = "0750";
              };
              "/var/lib/noctalia-greeter/greeter.toml"."L+" = {
                argument = "${greeterConfig}";
                user = "greeter";
                group = "greeter";
              };
            };

            "10-display-manager" = {
              "/etc/systemd/system/display-manager.service"."L+" = {
                argument = "/etc/systemd/system/greetd.service";
              };
            };

            # Debian 12's polkit does not read actions from /etc, so put the
            # greeter's action where the packaged polkit will find it.
            "10-noctalia-greeter-polkit" = {
              "/usr/share/polkit-1/actions/org.noctalia.greeter.apply-appearance.policy"."C+" = {
                argument = "${greeter}/share/polkit-1/actions/org.noctalia.greeter.apply-appearance.policy";
                mode = "0644";
              };
            };
          };

          environment.etc = {
            "greetd/config.toml".text = ''
              [default_session]
              command = "${greeterSession}"
              user = "greeter"

              [terminal]
              vt = 1
            '';

            "pam.d/greetd" = {
              # greetd is a Nix build linked against Nix's libpam. Keep the
              # rest of the stack on Nix's modules too, and use Nix's
              # pam_systemd to register the session with the host's logind.
              text = ''
                auth       [success=1 default=ignore]  pam_unix.so nullok
                auth       requisite                   pam_deny.so
                auth       required                    pam_permit.so

                account    [success=1 default=ignore]  pam_unix.so
                account    required                    pam_permit.so

                password   [success=1 default=ignore]  pam_unix.so
                password   requisite                   pam_deny.so
                password   required                    pam_permit.so

                session    required                    pam_unix.so
                session    optional                    ${pamSystemd}
                session    optional                    pam_keyinit.so force revoke
                session    required                    pam_loginuid.so
              '';
              mode = "0644";
            };

            "polkit-1/rules.d/49-noctalia-greeter-sync.rules" = {
              text = ''
                polkit.addRule(function(action, subject) {
                  var allowedUsers = ["josh"];
                  var program = action.lookup("program");
                  if (action.id == "org.noctalia.greeter.sync-appearance" &&
                      (program == "${lib.getExe' greeter "noctalia-greeter-apply-appearance"}" ||
                       program == "/run/system-manager/sw/bin/noctalia-greeter-apply-appearance") &&
                      action.lookup("user") == "root" &&
                      subject.local && subject.active &&
                      allowedUsers.indexOf(subject.user) >= 0) {
                    return polkit.Result.YES;
                  }
                });
              '';
              mode = "0644";
              replaceExisting = true;
            };
          };
        }
      )
    ];
  };
}
