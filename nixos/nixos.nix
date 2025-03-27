{
  inputs,
  lib,
  ...
}: let
  username = "demeter";
in {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./system.nix
    ./audio.nix
    ./locale.nix
    ./nautilus.nix
    ./laptop.nix
    ./hyprland.nix
    ./gnome.nix
  ];

  hyprland.enable = true;
  asusLaptop.enable = false;

  users.users.${username} = {
    isNormalUser = true;
    initialPassword = username;
    extraGroups = [
      "nixosvmtest"
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "libvirtd"
      "docker"
    ];
  };

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    users.${username} = {
      home.username = username;
      home.homeDirectory = "/home/${username}";
      imports = [
        ../home/nvim.nix
        ../home/ags.nix
        ../home/blackbox.nix
        ../home/browser.nix
        ../home/dconf.nix
        ../home/distrobox.nix
        ../home/git.nix
        ../home/hyprland.nix
        ../home/lf.nix
        ../home/packages.nix
        ../home/sh.nix
        ../home/starship.nix
        ../home/theme.nix
        ../home/tmux.nix
        ../home/wezterm.nix
        ./home.nix
      ];
    };
  };

  specialisation = {
    gnome.configuration = {
      system.nixos.tags = ["Gnome"];
      hyprland.enable = lib.mkForce false;
      gnome.enable = true;
    };
  };
}
