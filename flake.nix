# flake.nix
#
# This file packages pythoneda-realm-unveilingpartner/application as a Nix flake.
#
# Copyright (C) 2023-today rydnr's pythoneda-realm-unveilingpartner-def/application
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Nix flake for pythoneda-realm-unveilingpartner/application";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
    pythoneda-realm-unveilingpartner-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-realm-unveilingpartner-def/infrastructure/0.0.88";
    };
    pythoneda-realm-unveilingpartner-realm = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-realm-unveilingpartner-def/realm/0.0.74";
    };
    pythoneda-shared-pythonlang-application = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-shared-pythonlang-def/application/0.0.116";
    };
    pythoneda-shared-pythonlang-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:pythoneda-shared-pythonlang-def/banner/0.0.83";
    };
    pythoneda-shared-pythonlang-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      url = "github:pythoneda-shared-pythonlang-def/domain/0.0.123";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "pythoneda-realm-unveilingpartner";
        repo = "application";
        version = "0.0.11";
        sha256 = "07f70xs7c1a9yapdj4a58adj1pyv993f3z1v9g6p4kscpqia5zz8";
        pname = "${org}-${repo}";
        pythonpackage = builtins.replaceStrings [ "-" ] [ "." ] pname;
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        entrypoint = "unveilingpartner_app";
        description =
          "Application layer for pythoneda-realm-unveilingpartner/realm";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = with pkgs.lib.maintainers;
          [ "unveilingpartner <github@acm-sl.org>" ];
        archRole = "R";
        space = "D";
        layer = "A";
        nixpkgsVersion = builtins.replaceStrings [ "\n" ] [ "" ]
          (builtins.readFile "${nixpkgs}/.version");
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixpkgs-${nixpkgsVersion}";
        shared = import "${pythoneda-shared-pythonlang-banner}/nix/shared.nix";
        pkgs = import nixpkgs { inherit system; };
        pythoneda-realm-unveilingpartner-application-for = { python
          , pythoneda-realm-unveilingpartner-infrastructure
          , pythoneda-realm-unveilingpartner-realm
          , pythoneda-shared-pythonlang-application
          , pythoneda-shared-pythonlang-banner
          , pythoneda-shared-pythonlang-domain }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
            banner_file = "${package}/unveilingpartner_banner.py";
            banner_class = "UnveilingpartnerBanner";
          in python.pkgs.buildPythonApplication rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTomlTemplate = ./templates/pyproject.toml.template;
            pyprojectToml = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage package pname pythonMajorMinorVersion
                pythonpackage version;
              pythonedaRealmUnveilingpartnerInfrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.version;
              pythonedaRealmUnveilingpartnerRealm =
                pythoneda-realm-unveilingpartner-realm.version;
              pythonedaSharedPythonlangApplication =
                pythoneda-shared-pythonlang-application.version;
              pythonedaSharedPythonlangBanner =
                pythoneda-shared-pythonlang-banner.version;
              pythonedaSharedPythonlangDomain =
                pythoneda-shared-pythonlang-domain.version;
              src = pyprojectTomlTemplate;
            };
            bannerTemplateFile =
              "${pythoneda-shared-pythonlang-banner}/templates/banner.py.template";
            bannerTemplate = pkgs.substituteAll {
              project_name = pname;
              file_path = banner_file;
              inherit banner_class org repo;
              tag = version;
              pescio_space = space;
              arch_role = archRole;
              hexagonal_layer = layer;
              python_version = pythonMajorMinorVersion;
              nixpkgs_release = nixpkgsRelease;
              src = bannerTemplateFile;
            };
            entrypointTemplateFile =
              "${pythoneda-shared-pythonlang-banner}/templates/entrypoint.sh.template";
            entrypointTemplate = pkgs.substituteAll {
              arch_role = archRole;
              hexagonal_layer = layer;
              nixpkgs_release = nixpkgsRelease;
              inherit homepage maintainers org python repo version;
              pescio_space = space;
              python_version = pythonMajorMinorVersion;
              pythoneda_shared_banner = pythoneda-shared-pythonlang-banner;
              pythoneda_shared_domain = pythoneda-shared-pythonlang-domain;
              src = entrypointTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-realm-unveilingpartner-infrastructure
              pythoneda-realm-unveilingpartner-realm
              pythoneda-shared-pythonlang-application
              pythoneda-shared-pythonlang-banner
              pythoneda-shared-pythonlang-domain
            ];

            # pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              command cp -r ${src}/* .
              command chmod -R +w .
              command cp ${pyprojectToml} ./pyproject.toml
              command cp ${bannerTemplate} ./${banner_file}
              command cp ${entrypointTemplate} ./entrypoint.sh
            '';

            postPatch = ''
              substituteInPlace ./entrypoint.sh \
                --replace "@SOURCE@" "$out/bin/${entrypoint}.sh" \
                --replace "@PYTHONPATH@" "$PYTHONPATH" \
                --replace "@ENTRYPOINT@" "$out/lib/python${pythonMajorMinorVersion}/site-packages/${package}/${entrypoint}.py"
            '';

            postInstall = with python.pkgs; ''
              for f in $(command find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  command cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              command mkdir -p $out/dist $out/bin $out/deps/flakes
              command cp dist/${wheelName} $out/dist
              command cp ./entrypoint.sh $out/bin/${entrypoint}.sh
              command chmod +x $out/bin/${entrypoint}.sh
              for dep in ${pythoneda-realm-unveilingpartner-infrastructure} ${pythoneda-realm-unveilingpartner-realm} ${pythoneda-shared-pythonlang-application} ${pythoneda-shared-pythonlang-banner} ${pythoneda-shared-pythonlang-domain}; do
                command cp -r $dep/dist/* $out/deps || true
                if [ -e $dep/deps ]; then
                  command cp -r $dep/deps/* $out/deps || true
                fi
                METADATA=$dep/lib/python${pythonMajorMinorVersion}/site-packages/*.dist-info/METADATA
                NAME="$(command grep -m 1 '^Name: ' $METADATA | command cut -d ' ' -f 2)"
                VERSION="$(command grep -m 1 '^Version: ' $METADATA | command cut -d ' ' -f 2)"
                command ln -s $dep $out/deps/flakes/$NAME-$VERSION || true
              done
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default = pythoneda-realm-unveilingpartner-application-python312;
          pythoneda-realm-unveilingpartner-application-python39 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-realm-unveilingpartner-application-python39;
              inherit entrypoint;
            };
          pythoneda-realm-unveilingpartner-application-python310 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-realm-unveilingpartner-application-python310;
              inherit entrypoint;
            };
          pythoneda-realm-unveilingpartner-application-python311 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-realm-unveilingpartner-application-python311;
              inherit entrypoint;
            };
          pythoneda-realm-unveilingpartner-application-python312 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-realm-unveilingpartner-application-python312;
              inherit entrypoint;
            };
          pythoneda-realm-unveilingpartner-application-python313 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-realm-unveilingpartner-application-python313;
              inherit entrypoint;
            };
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-realm-unveilingpartner-application-python312;
          pythoneda-realm-unveilingpartner-application-python39 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-realm-unveilingpartner-application-python39;
              python = pkgs.python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-python310 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-realm-unveilingpartner-application-python310;
              python = pkgs.python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-python311 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-realm-unveilingpartner-application-python311;
              python = pkgs.python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-python312 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-realm-unveilingpartner-application-python312;
              python = pkgs.python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-python313 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-realm-unveilingpartner-application-python313;
              python = pkgs.python313;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313;
              inherit archRole layer org pkgs repo space;
            };
        };
        packages = rec {
          default = pythoneda-realm-unveilingpartner-application-python312;
          pythoneda-realm-unveilingpartner-application-python39 =
            pythoneda-realm-unveilingpartner-application-for {
              python = pkgs.python39;
              pythoneda-realm-unveilingpartner-infrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.packages.${system}.pythoneda-realm-unveilingpartner-infrastructure-python39;
              pythoneda-realm-unveilingpartner-realm =
                pythoneda-realm-unveilingpartner-realm.packages.${system}.pythoneda-realm-unveilingpartner-realm-python39;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python39;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
            };
          pythoneda-realm-unveilingpartner-application-python310 =
            pythoneda-realm-unveilingpartner-application-for {
              python = pkgs.python310;
              pythoneda-realm-unveilingpartner-infrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.packages.${system}.pythoneda-realm-unveilingpartner-infrastructure-python310;
              pythoneda-realm-unveilingpartner-realm =
                pythoneda-realm-unveilingpartner-realm.packages.${system}.pythoneda-realm-unveilingpartner-realm-python310;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python310;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
            };
          pythoneda-realm-unveilingpartner-application-python311 =
            pythoneda-realm-unveilingpartner-application-for {
              python = pkgs.python311;
              pythoneda-realm-unveilingpartner-infrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.packages.${system}.pythoneda-realm-unveilingpartner-infrastructure-python311;
              pythoneda-realm-unveilingpartner-realm =
                pythoneda-realm-unveilingpartner-realm.packages.${system}.pythoneda-realm-unveilingpartner-realm-python311;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python311;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
            };
          pythoneda-realm-unveilingpartner-application-python312 =
            pythoneda-realm-unveilingpartner-application-for {
              python = pkgs.python312;
              pythoneda-realm-unveilingpartner-infrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.packages.${system}.pythoneda-realm-unveilingpartner-infrastructure-python312;
              pythoneda-realm-unveilingpartner-realm =
                pythoneda-realm-unveilingpartner-realm.packages.${system}.pythoneda-realm-unveilingpartner-realm-python312;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python312;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
            };
          pythoneda-realm-unveilingpartner-application-python313 =
            pythoneda-realm-unveilingpartner-application-for {
              python = pkgs.python313;
              pythoneda-realm-unveilingpartner-infrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.packages.${system}.pythoneda-realm-unveilingpartner-infrastructure-python313;
              pythoneda-realm-unveilingpartner-realm =
                pythoneda-realm-unveilingpartner-realm.packages.${system}.pythoneda-realm-unveilingpartner-realm-python313;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python313;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
            };
        };
      });
}
