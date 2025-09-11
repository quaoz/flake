{
  security.sudo-rs = {
    # use sudo-rs
    enable = true;

    # only allow members of the wheel group to execute sudo
    execWheelOnly = true;

    # shush
    extraConfig = ''
      Defaults !lecture
      Defaults pwfeedback
      Defaults env_keep += "EDITOR PATH DISPLAY"
      Defaults timestamp_timeout = 300
    '';
  };
}
