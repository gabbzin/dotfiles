# Hardware / energia / áudio / bluetooth — tudo versionado aqui.
# Motivo: Quickshell (Battery.qml, PowerProfile.qml, SystemStatus.qml) usa
# Quickshell.Services.UPower, que exige o daemon UPower ativo.
# Sem services.upower.enable, a bateria existe no kernel (/sys/class/power_supply/BAT0)
# mas aparece como "No battery / Unknown" no Hyprland.
{ pkgs, ... }:
let
  # Limite de carga do ThinkPad (80/85/90/95). Troca aqui + rebuild.
  # Começa a recarregar 5 pontos abaixo do limite (evita micro-ciclos no topo).
  chargeLimit = 80;
  chargeStart = chargeLimit - 5;
in
{
  # Bateria: UPower + power-profiles-daemon + powerManagement
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  powerManagement.enable = true;

  # Teto de carga via sysfs do thinkpad_acpi (oneshot tardio: sysfs já existe).
  # Runtime (sem rebuild): echo 85 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
  systemd.services.battery-charge-limit = {
    description = "Limita carga da bateria (ThinkPad)";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      echo ${toString chargeStart} > /sys/class/power_supply/BAT0/charge_control_start_threshold
      echo ${toString chargeLimit} > /sys/class/power_supply/BAT0/charge_control_end_threshold
    '';
  };

  # Áudio: PipeWire explícito e versionado (wpctl/wireplumber usados nos keybinds).
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Bluetooth: exigido pelo blueman-applet do autostart antigo e pelo módulo QML.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Digital (ELAN 04f3:0c8c): login (tuigreet) + sudo sem senha.
  # Se fprintd-enroll disser "no devices", ligar tod: services.fprintd.tod.enable = true.
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.greetd.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;

  # Ferramentas CLI usadas pelos atalhos QML/keybinds — antes ausentes no PATH:
  # brightnessctl (XF86MonBrightness*), playerctl (mídia), upower (debug),
  # grim+slurp (Print), wl-clipboard+cliphist (clipboard), pwvucontrol (audioSettings do Caelestia).
  environment.systemPackages = with pkgs; [
    upower
    brightnessctl
    playerctl
    grim
    slurp
    wl-clipboard
    cliphist
    pwvucontrol
    cava # visualizador de áudio do widget de mídia (Audio.cava)
  ];
}
