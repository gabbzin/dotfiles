-- WakaTime tracking leve (só heartbeat no save/focus, 0% idle).
-- wakatime-cli já vem via packages.nix. API key lida de ~/.wakatime.cfg.
return {
  { "wakatime/vim-wakatime", lazy = false },
}
