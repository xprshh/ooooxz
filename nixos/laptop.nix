{ config, pkgs, lib, ... }:

{
  options.asusLaptop = {
    enable = lib.mkEnableOption "Asus Laptop";
  };

  config = lib.mkIf config.asusLaptop.enable {
    # Enable Asus services
    services.asusd = {
      enable = true;
      enableUserService = true;
    };

    # Enable thermald for better thermal management
    services.thermald.enable = true;

    boot.kernelParams = [
      "intel_pstate=passive"
      "pcie_aspm=force"
      "usbcore.autosuspend=1"
      "acpi_osi=Linux"
      "acpi_backlight=vendor"
      "mem_sleep_default=deep"
      "intel_idle.max_cstate=9"
      "rcu_nocbs=0-7"  # Adjust based on `nproc`
      "nmi_watchdog=0"
      "i915.enable_fbc=1"
      "i915.enable_psr=1"
      "i915.enable_rc6=3"
    ];

    # Enable periodic trimming for Ext4 SSD
    services.fstrim.enable = true;

    systemd.sleep.extraConfig = ''
      SuspendState=mem
      HibernateState=disk
    '';

    # Kernel optimizations
    boot.kernel.sysctl = {
      "vm.laptop_mode" = 10;
      "vm.dirty_writeback_centisecs" = 3000;
    };

    # Enable Bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = false;  # Saves power by default

    # Enable OpenGL and Nvidia Optimus
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Nvidia PRIME offload for hybrid graphics
    hardware.nvidia = {
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        nvidiaBusId = "PCI:1:0:0";
        amdgpuBusId = "PCI:6:0:0";
      };

      modesetting.enable = true;

      open = true;
      nvidiaSettings = false; # GUI app disabled
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    # Xserver setup for Nvidia
    services.xserver.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];

    # Install power-saving utilities
    environment.systemPackages = with pkgs; [
      powertop
      acpi
      pciutils
      ethtool
      wayland-utils
      lm_sensors
    ];
  };
}
