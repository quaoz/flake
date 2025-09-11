{
  lib,
  config,
  ...
}: let
  inherit (config.garden.hardware) cpu;
in {
  config = lib.mkIf (cpu == "intel") {
    hardware.cpu.intel.updateMicrocode = true;

    boot.kernelModules = ["kvm-intel"];
  };
}
