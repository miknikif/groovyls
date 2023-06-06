{
  description = "Language Server (LS) for Groovy";
  inputs = {
    # Giant monorepo with recipes called derivations that say how to build software
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05"; # Can be nixpkgs-unstable
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in rec {
      packages.groovyls = pkgs.stdenv.mkDerivation rec {
        pname = "groovyls";
        version = "4866a3f2c180f628405b1e4efbde0949a1418c10";

        src = pkgs.fetchFromGitHub {
          owner = "GroovyLanguageServer";
          repo = "groovy-language-server";
          rev = version;
          sha256 = "sha256-LXCdF/cUYWy7mD3howFXexG0+fGfwFyKViuv9xZfgXc=";
        };

        nativeBuildInputs = with pkgs; [jdk gradle_7];
        phases = ["buildPhase" "installPhase"];
        GRADLE_OPTS = "-Dorg.gradle.project.buildDir=/tmp";
        GRADLE_USER_HOME = "/tmp";

        buildPhase = ''
          mkdir ${pname}
          cp -rT $src ${pname}
          pushd ${pname}
          gradle clean build
          popd
        '';

        installPhase = ''
          mkdir -p $out
          cp -rT ${pname}/build/libs $out
        '';
        meta = with pkgs.lib; {
          description = "Language Server (LS) for Groovy";
          homepage = "https://github.com/GroovyLanguageServer/groovy-language-server";
          sourceProvenance = with sourceTypes; [fromSource];
          license = licenses.asl20;
        };
      };
      packages.default = packages.groovyls;
      apps.groovyls = flake-utils.lib.mkApp {
        drv = packages.groovyls;
        name = "groovyls";
      };
      apps.default = apps.groovyls;
    });
}
