{ lib
, buildNpmPackage
, fetchFromGitHub
, python3
, nixosTests
, nix-update-script
}:

buildNpmPackage rec {
  pname = "zigbee2mqtt";
  version = "1.29.0";

  src = fetchFromGitHub {
    owner = "Koenkk";
    repo = "zigbee2mqtt";
    rev = version;
    hash = "sha256-WN8dLqHbx/NydGwYeksrfSHs9kpRWj1FY/t+/Noux+g=";
  };

  npmDepsHash = "sha256-PAUdNCZ5YgEyz72rjUz3gdUkjDxLTC3yh3kv4Vtix3Q=";

  nativeBuildInputs = [
    python3
  ];

  passthru.tests.zigbee2mqtt = nixosTests.zigbee2mqtt;
  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    changelog = "https://github.com/Koenkk/zigbee2mqtt/releases/tag/${version}";
    description = "Zigbee to MQTT bridge using zigbee-shepherd";
    homepage = "https://github.com/Koenkk/zigbee2mqtt";
    license = licenses.gpl3;
    longDescription = ''
      Allows you to use your Zigbee devices without the vendor's bridge or gateway.

      It bridges events and allows you to control your Zigbee devices via MQTT.
      In this way you can integrate your Zigbee devices with whatever smart home infrastructure you are using.
    '';
    maintainers = with maintainers; [ sweber hexa ];
    platforms = platforms.linux;
  };
}
