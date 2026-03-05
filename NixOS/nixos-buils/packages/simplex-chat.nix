{ pkgs }:

[
  pkgs.stdenv.mkDerivation {
    pname = "simplex-chat";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "simplex-chat";
      repo = "simplex-chat";
      rev = "stable";
      sha256 = "0000000000000000000000000000000000000000000000000000"; # fix this!
    };

    buildPhase = ''
      # your build commands here
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp ./result/simplex-chat $out/bin/
    '';

    meta = with pkgs.lib; {
      description = "Simplex Chat App";
      homepage = "https://github.com/simplex-chat/simplex-chat";
      license = licenses.mit;
    };
  }
]
