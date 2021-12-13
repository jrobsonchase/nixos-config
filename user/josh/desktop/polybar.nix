{ pkgs, ... }:
{
  services.polybar = {
    config = ./polybar.conf;
    package = pkgs.polybarFull;
    script = ''
      PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:${pkgs.iproute2}/bin:${pkgs.procps}/bin:''${PATH}

      set -x

      MONITORS=$(polybar -m | sed 's/:.*//')

      INTERFACES=$(ip link | grep -P '\d: en' | cut -d : -f 2 | tr -d ' ')
      ETH_CTR=1
      for iface in $INTERFACES; do
        eval "export POLYBAR_ETH''${ETH_CTR}=$iface"
        let ETH_CTR+=1
      done

      export POLYBAR_WLAN=$(ip link | grep -P '\d: wl' | cut -d : -f 2 | tr -d ' ')

      for monitor in $MONITORS
      do
        MONITOR=$monitor polybar -r i3 &
        sleep 0.5
      done
    '';
  };
}
