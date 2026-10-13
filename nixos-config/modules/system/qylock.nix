{ lib, pkgs, ... }:

{
  services.greetd.enable = lib.mkForce false;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.displayManager.defaultSession = "hyprland-uwsm";

  programs.qylock = {
    enable = true;
    theme = "clockwork/orbital";
    sddm.enable = true;
    quickshell.enable = true;
    themeOptions.clockwork.orbital = {
      themeMode = "dark";
      enableWindup = true;
    };
  };

  fonts.packages = with pkgs; [
    orbitron
  ];

  environment.systemPackages = with pkgs; [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
  ];
}
