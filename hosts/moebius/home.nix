_:

{
  conf = {
    cli.enable = true;
    coding.enable = true;
    colors.enable = true;
    desktop = {
      enable = true;
      terminalFontSize = 10;
      linux.enable = true;
      wayland.enable = true;
      x11.enable = false;
    };
    homeDefaults.system = "linux";
    up = {
      system = "nixos";
      additionalRoles = [ "coding" "gaming" ];
    };
  };

  wayland.windowManager.hyprland.settings.master.mfact = 0.66;
  services.kanshi.profiles.def.outputs = [{
    criteria = "DP-3";
    mode = "3440x1440@144.000";
  }];
  programs.autorandr.profiles = {
    "home" = {
      fingerprint = {
        DisplayPort-2 =
          "00ffffffffffff0061a9443400000000101e0104b55021783b64f5ad5049a322135054adcf00714f81c0814081809500a9c0b300d1c0226870a0d0a02950302035001d4e3100001a20fd70a0d0a03c50302035001d4e3100001e000000fd003090a0a03c010a202020202020000000fc004d69204d6f6e69746f720a202002ac020320f44c010203040590111213141f3f2309070783010000e6060701605d29023a801871382d40582c96001d4e3100001e20ac00a0a0382d40302035001d4e3100001ef0d270a0d0a03c50302035001d4e3100001ea348b86861a03250304035001d4e3100001ef57c70a0d0a02950302035001d4e3100001e00000000006b7012790000030014bf2f01046f0d9f002f001f009f053b000280040007000a0881000804000402100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e190";
      };
      config = {
        DisplayPort-0.enable = false;
        DisplayPort-1.enable = false;
        DisplayPort-2 = {
          enable = true;
          position = "0x0";
          mode = "3440x1440";
          rate = "120.00";
        };
      };
    };
    "home+tv" = {
      fingerprint = {
        DisplayPort-2 =
          "00ffffffffffff0061a9443400000000101e0104b55021783b64f5ad5049a322135054adcf00714f81c0814081809500a9c0b300d1c0226870a0d0a02950302035001d4e3100001a20fd70a0d0a03c50302035001d4e3100001e000000fd003090a0a03c010a202020202020000000fc004d69204d6f6e69746f720a202002ac020320f44c010203040590111213141f3f2309070783010000e6060701605d29023a801871382d40582c96001d4e3100001e20ac00a0a0382d40302035001d4e3100001ef0d270a0d0a03c50302035001d4e3100001ea348b86861a03250304035001d4e3100001ef57c70a0d0a02950302035001d4e3100001e00000000006b7012790000030014bf2f01046f0d9f002f001f009f053b000280040007000a0881000804000402100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e190";
        HDMI-A-0 =
          "00ffffffffffff001e6d3876010101010113010380462778ead9b0a357499c2511494ba1080031404540614081809040d1c0010101011a3680a070381f4030203500e8263200001a1b2150a051001e3048883500bc862100001c000000fd00394b1f5412000a202020202020000000fc0033374c47373030300a2020202001ca020325f15081020306071516121304140520221f10230957078301000067030c004000b82d011d008051d01c2040803500bc882100001e8c0ad08a20e02d10103e9600138e21000018023a801871382d40582c450006442100001e011d8018711c1620582c2500c48e2100009e4e1f008051001e3040803700bc8821000018ae";
      };
      config = {
        DisplayPort-0.enable = false;
        DisplayPort-1.enable = false;
        DisplayPort-2 = {
          enable = true;
          position = "0x0";
          mode = "3440x1440";
          rate = "120.00";
          crtc = 0;
        };
        HDMI-A-0 = {
          enable = true;
          position = "0x3440";
          mode = "1920x1080";
          rate = "60.00";
          crtc = 1;
        };
      };
    };
  };
}