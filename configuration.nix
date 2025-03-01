# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import the unstable channel
  unstable = import <nixos-unstable> {
    config = config.nixpkgs.config;
  };
  local-unstable = import /home/lopk/nixpkgs {
    config = config.nixpkgs.config;
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    /home/lopk/nixpkgs/nixos/modules/programs/perf.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = local-unstable.linuxPackages_latest;
  boot.extraModprobeConfig = ''
    # example settings
    options amdgpu vm_update_mode=0 vm_fault_stop=0 debug_evictions=true vcnfw_log=1 mes=1 mes_log_enable=1 mes_kiq=1
  '';
  boot.tmp.useTmpfs = true;
  # allow perf as user
  #boot.kernel.sysctl."kernel.perf_event_paranoid" = -1; # cap_perfmon bypasses this setting
  #boot.kernel.sysctl."kernel.kptr_restrict" = lib.mkForce 0; # setting this to 1 should work with cap_syslog
  programs.perf.enable = true;

  networking.hostName = "lopk"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.wireless.enable = false; # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "pl_PL.UTF-8";
  console = {
    font = "eurlatgr"; # I prefer "Lat2-Terminus16"; visually but It doesn't load automatically so at most I can manually setfont to it
    keyMap = "pl";
    useXkbConfig = false; # use xkb.options in tty.
  };
  # Experimental kmscon
  services.kmscon = {
    enable = true;
    hwRender = true;
    autologinUser = "lopk";
    extraConfig = "
	    xkb-layout=pl
	    xkb-options=grp:win_space_toggle,compose:rctrl
	    "; # kmscon in version 9 has a script that should take xkb config from localectl
    #fonts = [ { name = "Source Code Pro"; package = pkgs.source-code-pro; } ];
  };
  #  Failed multiseat setup with, seat isn't constucted properly
  #  environment.etc.seat = {
  #    target = "udev/rules.d/72-myrules.rules";
  #    text = ''
  #TAG=="seat", ENV{ID_FOR_SEAT}=="drm-pci-0000_0c_00_0", ENV{ID_SEAT}="seat1"
  #TAG=="seat", ENV{ID_FOR_SEAT}=="graphics-pci-0000_0c_00_0", ENV{ID_SEAT}="seat1"
  #TAG=="seat", ENV{ID_FOR_SEAT}=="usb-pci-0000_0e_00_3-usb-0_2", ENV{ID_SEAT}="seat1"
  #TAG=="seat", ENV{ID_FOR_SEAT}=="usb-pci-0000_0e_00_3-usb-0_3", ENV{ID_SEAT}="seat1"
  #TAG=="seat", ENV{ID_FOR_SEAT}=="usb-pci-0000_0e_00_3-usb-0_4", ENV{ID_SEAT}="seat1"
  #    '';
  #  };

  services.displayManager.defaultSession = "sway";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.sway.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "lopk";

  security.polkit.enable = true;
  services.logrotate.enable = false; # logrotate is leaking bpf programs and maps
  #services.gnome.gnome-keyring.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  hardware.pulseaudio.enable = false; # Conflict with pipewire requires false

  # Fonts
  fonts.packages = with pkgs; [
    unstable.nerd-fonts.symbols-only
  ];

  # Configure keymap in X11
  services.xserver.xkb.layout = "pl,de,us";
  services.xserver.xkb.options = "grp:win_space_toggle,compose:rctrl"; # use xkbcli to check available options

  # Enable CUPS to print documents.
  services.printing.enable = true;
  hardware.sane.enable = true; # enables support for SANE scanners
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ]; # pkgs.sane-airscan
  hardware.sane.netConf = "LASER.local";
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  # Ollama 	watch out for version
  #services.ollama = {
  #  enable = true;
  #  acceleration = "rocm";
  #  environmentVariables = {
  #    HSA_OVERRIDE_GFX_VERSION="10.3.0";
  #  };
  #};

  hardware.amdgpu.opencl.enable = true;
  hardware.graphics.enable = true;
  /*
    hardware.graphics.extraPackages = [
      pkgs.rocmPackages.clr.icd
      pkgs.amdvlk
    ];
  */

  users.users.lopk = {
    isNormalUser = true;
    initialPassword = "lopk";
    extraGroups = [
      "wheel"
      "scanner"
      "lp"
      "libvirtd"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      #tree
    ];
  };

  nixpkgs.config.allowUnfree = true;
  services.flatpak.enable = true;
  programs.systemtap.enable = true; # better check max supported kernel version
  programs.bcc.enable = true;
  programs.sysdig.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.variables = {
    EDITOR = "vim";
  };
  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs; [
    vim
    firefox
    hotspot
    mpv
    git
    gh
    man-pages-posix
    man-pages
    tmux
    alacritty
    home-manager
    wl-clipboard
    arcan
    tracy
    dive
    podman-tui
    podman-compose
    gdb
    lsof
    file
    bpftools
    nixfmt-rfc-style
    umr
  ];
  services.nixseparatedebuginfod.enable = true;
  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
