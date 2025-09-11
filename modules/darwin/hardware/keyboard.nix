{
  system = {
    keyboard = {
      # enable key mapping
      enableKeyMapping = true;

      # remap caps to escape
      remapCapsLockToEscape = true;
    };

    defaults.NSGlobalDomain = {
      # full keyboard control
      AppleKeyboardUIMode = 3;

      # disable press and hold
      ApplePressAndHoldEnabled = false;

      # disable auto capitalisation and friends
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # shorter key repeat delay
      InitialKeyRepeat = 15;

      # faster key repeat
      KeyRepeat = 1;
    };
  };
}
