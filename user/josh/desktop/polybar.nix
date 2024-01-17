{ pkgs, ... }:
{
  services.polybar = {
    config = ./polybar.conf;
    package = pkgs.polybarFull;
    script = ''
      PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:${pkgs.iproute2}/bin:${pkgs.procps}/bin:''${PATH}

      set -ex

      MONITORS=$(polybar -m | sed 's/:.*//')

      INTERFACES=$(ip link | grep -P '\d: en' | cut -d : -f 2 | tr -d ' ')
      ETH_CTR=1
      for iface in $INTERFACES; do
        eval "export POLYBAR_ETH''${ETH_CTR}=$iface"
        let ETH_CTR+=1
      done

      export POLYBAR_WLAN=$(ip link | grep -P '\d: wl' | cut -d : -f 2 | tr -d ' ')

      function start_bars() {
        # This is a hack to make sure the bars actually exit. For some reason
        # (usually when adding/removing monitors), they'll sometimes ignore
        # SIGTERM and keep right on truckin'. There's not really anything that
        # they should need to clean up with a clean exit, so force-kill them
        # with SIGKILL.
        BARS=()
        function kill_bars() {
          for pid in ''${BARS[@]}; do
            kill -9 $pid
          done
          exit 0
        }

        for monitor in $MONITORS
        do
          MONITOR=$monitor polybar -c ${./polybar.conf} i3 &
          BARS+=( ''$! )
          sleep 0.5
        done

        wait

        exit 1
      }

      start_bars &

      disown
    '';
  };
}
