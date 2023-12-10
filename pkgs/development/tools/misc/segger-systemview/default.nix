{ stdenv
, fetchurl
, fontconfig
, freetype
, lib
, libICE
, libSM
, udev
, libX11
, libXcursor
, libXext
, libXfixes
, libXrandr
, libXrender
}:

stdenv.mkDerivation rec {
  pname = "segger-systemview";
  version = "3.52a";

  src = fetchurl {
    url = "https://www.segger.com/downloads/systemview/SystemView_Linux_V${(lib.replaceStrings ["."] [""] version)}_x86_64.tgz";
    hash = "sha256-0+yNVK4GBaQNEtbu6oCWc2LtPtkhOV8VTv7o1l0MJe4=";
  };

  rpath = lib.makeLibraryPath [
    fontconfig
    freetype
    libICE
    libSM
    udev
    libX11
    libXcursor
    libXext
    libXfixes
    libXrandr
    libXrender
  ]
  + ":${stdenv.cc.cc.lib}/lib64";

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    mv * $out
    mv $out/SystemView $out/bin
    mv $out/*.so* $out/lib
  '';

  postFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/bin/SystemView" \
      --set-rpath ${rpath}:$out/lib "$out/bin/SystemView"

    for file in $(find $out/lib -maxdepth 1 -type f -and -name \*.so\*); do
      patchelf --set-rpath ${rpath}:$out/lib $file
    done
  '';

  meta = with lib; {
    description = "Real-time Analyzer and Visualization Tool for Embedded Systems";
    longDescription = ''
      SystemView is a real-time analyzer and visualization tracing tool for embedded systems.

        - Display interrupt handler timing
        - Display thread timing and run status
    '';
    homepage = "https://www.segger.com/products/development-tools/systemview";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = [ maintainers.teburd ];
    platforms = [ "x86_64-linux" ];
  };
}

