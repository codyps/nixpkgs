{ stdenv, texinfo, flex, bison, fetchFromGitHub, crossLibcStdenv, buildPackages }:

crossLibcStdenv.mkDerivation {
  name = "newlib";

  # https://github.com/espressif/newlib-esp32/releases/tag/esp-2022r1
  src = [
    fetchFromGitHub {
      owner = "espressif";
      repo = "newlib-esp32";
      rev = "12fd7ea6b9fd2d13abe6874c583767b5b8844acd";
      sha256 = stdenv.lib.fakeSha256;
    },

    fetchFromGitHub {
      owner = "espressif";
      repo = "xtensa-overlays";
      rev = "dd1cf19f6eb327a9db51043439974a6de13f5c7f";
      sha256 = lib.fakeSha256;
    }
  ];

  # FIXME: use `targetPlatform` to pick the correct overlay to apply

  # newlib expects CC to build for build platform, not host platform
  preConfigure = ''
    export CC=cc
  '';

  dontUpdateAutotoolsGnuConfigScripts = true;
  configurePlatforms = [ "target" ];
  enableParallelBuilding = true;

  nativeBuildInputs = [ texinfo flex bison ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  dontStrip = true;

  passthru = {
    incdir = "/${stdenv.targetPlatform.config}/include";
    libdir = "/${stdenv.targetPlatform.config}/lib";
  };
}
