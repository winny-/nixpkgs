{ config
, stdenv
, lib
, fetchFromGitHub
, makeWrapper
, makePerlPath

# Perl libraries
, LWP

# Required
, perl
, hwinfo
, dmidecode
, smartmontools
, pciutils
, usbutils
, edid-decode

# Conditionally recommended
, systemdSupport ? config.systemdSupport or stdenv.hostPlatform.isLinux
, systemd

# Recommended
, withRecommended ? false # Install recommended tools
, mcelog
, hdparm
, acpica-tools
, drm_info
, mesa-demos
, memtester
, sysstat
, cpuid
, util-linuxMinimal
, xinput
, libva-utils
, inxi
, vulkan-utils
, i2c-tools
, opensc

# Suggested
, withSuggested ? false # Install (most) suggested tools
, hplip
, sane-backends
, pnputils ? null # pnputils (lspnp) isn't currently in nixpkgs and appears to be poorly maintained
}:

stdenv.mkDerivation rec {
  pname = "hw-probe";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "linuxhw";
    repo = pname;
    rev = version;
    sha256 = "sha256:028wnhrbn10lfxwmcpzdbz67ygldimv7z1k1bm64ggclykvg5aim";
  };

  makeFlags = [ "prefix=$(out)" ];

  buildInputs = [ perl ];
  nativeBuildInputs = [ makeWrapper ];

  makeWrapperArgs =
    let
      requiredPrograms = [
        hwinfo
        dmidecode
        smartmontools
        pciutils
        usbutils
        edid-decode
      ];
      recommendedPrograms = [
        mcelog
        hdparm
        acpica-tools
        drm_info
        mesa-demos
        memtester
        sysstat # (iostat)
        cpuid
        util-linuxMinimal # (rfkill)
        xinput
        libva-utils # (vainfo)
        inxi
        vulkan-utils
        i2c-tools
        opensc
      ];
      conditionallyRecommendedPrograms = lib.concatLists [
        (lib.optional systemdSupport systemd) # (systemd-analyze)
      ];
      suggestedPrograms = [
        hplip # (hp-probe)
        sane-backends # (sane-find-scanner)
        pnputils # (lspnp)
      ];
      programs =
        requiredPrograms
        ++ conditionallyRecommendedPrograms
        ++ lib.optionals withRecommended recommendedPrograms
        ++ lib.optionals withSuggested suggestedPrograms;
    in [
      "--set" "PERL5LIB" "${makePerlPath [ LWP ]}"
      "--prefix" "PATH" ":" "${lib.makeBinPath programs}"
    ];

  postInstall = ''
    wrapProgram $out/bin/hw-probe \
      $makeWrapperArgs
  '';

  meta = with lib; {
    description = "Probe for hardware, check operability and find drivers";
    homepage = "github.com/linuxhw/hw-probe";
    platforms = with platforms; (linux ++ freebsd ++ netbsd ++ openbsd);
    license = with licenses; [ lgpl21 bsdOriginal ];
    maintainers = with maintainers; [ rehno-lindeque  ];
  };
}
