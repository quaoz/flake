{
  networking.applicationFirewall = {
    enable = true;

    # allow builtin software
    allowSignedApp = false;
    allowSigned = true;

    blockAllIncoming = false;
    enableStealthMode = true;
  };
}
