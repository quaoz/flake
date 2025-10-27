{lib, ...}: {
  mkEnvFile = dependencies: {
    inherit dependencies;

    script = {
      deps,
      decrypt,
      ...
    }:
      lib.mapAttrsToList (var: secret: "echo \"${var}='$(${decrypt} ${lib.escapeShellArg secret.file})'\"") deps
      |> builtins.concatStringsSep "\n";
  };
}
