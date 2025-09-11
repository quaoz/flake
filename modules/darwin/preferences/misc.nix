{
  system.defaults.CustomUserPreferences = {
    # add context menu item for showing web inspector in web views
    NSGlobalDomain.WebKitDeveloperExtras = true;

    "com.apple.desktopservices" = {
      # dont create .DS_Store files on network or usb volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
  };
}
