{
  lib,
  config,
  ...
}: let
  cfg = config.garden.hardware.audio;
in {
  options.garden.hardware.audio.enable = lib.mkEnableOption "audio support";

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      audio.enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };
}
