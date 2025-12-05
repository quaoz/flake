{
  lib,
  osConfig,
  ...
}: let
  plugins =
    lib.genAttrs [
      # keep-sorted start
      "AlwaysTrust"
      "BadgeAPI"
      "BetterFolders"
      "BetterGifAltText"
      "BetterGifPicker"
      "BetterSessions"
      "BetterSettings"
      "BetterUploadButton"
      "BiggerStreamPreview"
      "CallTimer"
      "ClearURLs"
      "CommandsAPI"
      "ConsoleJanitor"
      "ConsoleShortcuts"
      "CopyFileContents"
      "CrashHandler"
      "Dearrow"
      "DisableCallIdle"
      "DisableDeepLinks"
      "DontRoundMyTimestamps"
      "FakeNitro"
      "FavoriteGifSearch"
      "FixCodeblockGap"
      "FixImagesQuality"
      "FixSpotifyEmbeds"
      "FixYoutubeEmbeds"
      "FriendInvites"
      "FriendsSince"
      "GameActivityToggle"
      "GifPaste"
      "GreetStickerPicker"
      "ImageFilename"
      "ImageZoom"
      "ImplicitRelationships"
      "MemberListDecoratorsAPI"
      "MessageAccessoriesAPI"
      "MessageClickActions"
      "MessageDecorationsAPI"
      "MessageEventsAPI"
      "MessageLatency"
      "MessageLogger"
      "MessageUpdaterAPI"
      "NoDevtoolsWarning"
      "NoF1"
      "NoTrack"
      "NoUnblockToJump"
      "NormalizeMessageLinks"
      "PlatformIndicators"
      "ReactErrorDecoder"
      "ReverseImageSearch"
      "Settings"
      "ShikiCodeblocks"
      "ShowConnections"
      "SpotifyControls"
      "SpotifyCrack"
      "SupportHelper"
      "Translate"
      "TypingTweaks"
      "Unindent"
      "UserSettingsAPI"
      "ValidReply"
      "ValidUser"
      "ViewRaw"
      "VoiceChatDoubleClick"
      "VoiceDownload"
      "VolumeBooster"
      "WebContextMenus"
      "WebKeybinds"
      "WebScreenShareFixes"
      "YoutubeAdblock"
      "petpet"
      # keep-sorted end
    ] (_: {
      enabled = true;
    });
in {
  # discord client
  programs.vesktop = lib.mkIf osConfig.garden.profiles.desktop.enable {
    enable = true;

    settings = {
      discordBranch = "stable";
      arRPC = true;
      disableMinSize = true;
      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;
    };

    vencord.settings = {
      inherit plugins;

      autoUpdate = false;
      autoUpdateNotification = false;
    };
  };
}
