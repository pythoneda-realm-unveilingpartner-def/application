# application/flake.nix
#
# This file packages pythoneda-realm-unveilingpartner/application as a Nix flake.
#
# Copyright (C) 2023-today rydnr's pythoneda-realm-unveilingpartner/application-artifact
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
  description = "Application layer for pythoneda-realm-unveilingpartner/realm";
  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-realm-unveilingpartner-infrastructure = {
      url =
        "github:pythoneda-realm-unveilingpartner/infrastructure-artifact/0.0.1a2?dir=infrastructure";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-realm-unveilingpartner-realm.follows =
        "pythoneda-realm-unveilingpartner-realm";
      inputs.pythoneda-shared-pythoneda-banner.follows =
        "pythoneda-shared-pythoneda-banner";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-realm-unveilingpartner-realm = {
      url =
        "github:pythoneda-realm-unveilingpartner/realm-artifact/0.0.1a2?dir=realm";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-banner.follows =
        "pythoneda-shared-pythoneda-banner";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-shared-pythoneda-application = {
      url =
        "github:pythoneda-shared-pythoneda/application-artifact/0.0.1a32?dir=application";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-banner.follows =
        "pythoneda-shared-pythoneda-banner";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-shared-pythoneda-banner = {
      url = "github:pythoneda-shared-pythoneda/banner/0.0.1a17";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-shared-pythoneda-domain = {
      url =
        "github:pythoneda-shared-pythoneda/domain-artifact/0.0.1a43?dir=domain";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-banner.follows =
        "pythoneda-shared-pythoneda-banner";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "pythoneda-realm-unveilingpartner";
        repo = "application";
        version = "0.0.1a3";
        sha256 = "sha256-4L4N5gZFDJ/+QrClvgBxWe6SsIRCKu19SNLkrRFT+mE=";
        pname = "${org}-${repo}";
        pythonpackage = builtins.replaceStrings [ "-" ] [ "." ] pname;
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        app = "unveilingpartner_app";
        entrypoint = "${pname}.sh";
        description =
          "Application layer for pythoneda-realm-unveilingpartner/realm";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = with pkgs.lib.maintainers;
          [ "unveilingpartner <github@acm-sl.org>" ];
        archRole = "R";
        space = "D";
        layer = "A";
        nixosVersion = builtins.replaceStrings [ "\n" ] [ "" ]
          (builtins.readFile "${nixos}/.version");
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-pythoneda-banner}/nix/shared.nix";
        pkgs = import nixos { inherit system; };
        pythoneda-realm-unveilingpartner-application-for = { python
          , pythoneda-realm-unveilingpartner-infrastructure
          , pythoneda-realm-unveilingpartner-realm
          , pythoneda-shared-pythoneda-application
          , pythoneda-shared-pythoneda-banner, pythoneda-shared-pythoneda-domain
          }:
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
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage package pname pythonMajorMinorVersion
                pythonpackage version;
              pythonedaRealmUnveilingpartnerInfrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.version;
              pythonedaRealmUnveilingpartnerRealm =
                pythoneda-realm-unveilingpartner-realm.version;
              pythonedaSharedPythonedaApplication =
                pythoneda-shared-pythoneda-application.version;
              pythonedaSharedPythonedaBanner =
                pythoneda-shared-pythoneda-banner.version;
              pythonedaSharedPythonedaDomain =
                pythoneda-shared-pythoneda-domain.version;
              src = pyprojectTemplateFile;
            };
            bannerTemplateFile =
              "${pythoneda-shared-pythoneda-banner}/templates/banner.py.template";
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

            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-realm-unveilingpartner-infrastructure
              pythoneda-realm-unveilingpartner-realm
              pythoneda-shared-pythoneda-application
              pythoneda-shared-pythoneda-banner
              pythoneda-shared-pythoneda-domain
            ];

            pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod -R +w $sourceRoot
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
              cp ${bannerTemplate} $sourceRoot/${banner_file}
              cat $sourceRoot/flake.nix
              cp entrypoint.sh $sourceRoot/
            '';

            postPatch = ''
              substituteInPlace /build/$sourceRoot/entrypoint.sh \
                --replace "@ORG@" "${org}" \
                --replace "@REPO@" "${repo}" \
                --replace "@VERSION@" "${version}" \
                --replace "@PESCIO_SPACE@" "${space}" \
                --replace "@ARCH_ROLE@" "${archRole}" \
                --replace "@HEXAGONAL_LAYER@" "${layer}" \
                --replace "@PYTHON@" "${python}" \
                --replace "@PYTHONPATH@" "$PYTHONPATH" \
                --replace "@ENTRYPOINT@" "$out/lib/python${pythonMajorMinorVersion}/site-packages/${package}/${entrypoint}.py" \
                --replace "@PYTHONEDA_SHARED_PYTHONEDA_DOMAIN@" "${pythoneda-shared-pythoneda-domain}" \
                --replace "@PYTHONEDA_SHARED_PYTHONEDA_BANNER@" "${pythoneda-shared-pythoneda-banner}" \
                --replace "@PYTHON_VERSION@" "${python.version}" \
                --replace "@NIXPKGS_RELEASE@" "${nixosVersion}"
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist $out/bin
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
              cp /build/$sourceRoot/entrypoint.sh $out/bin/${entrypoint}
              chmod +x $out/bin/${entrypoint}
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default = pythoneda-realm-unveilingpartner-application-default;
          pythoneda-realm-unveilingpartner-application-default =
            pythoneda-realm-unveilingpartner-application-python311;
          pythoneda-realm-unveilingpartner-application-python38 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-realm-unveilingpartner-application-python38;
              inherit entrypoint;
            };
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
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-realm-unveilingpartner-application-default;
          pythoneda-realm-unveilingpartner-application-default =
            pythoneda-realm-unveilingpartner-application-python311;
          pythoneda-realm-unveilingpartner-application-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-realm-unveilingpartner-application-python38;
              python = pkgs.python38;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python38;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python38;
              inherit archRole layer nixpkgsRelease org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-raw-python38 =
            shared.raw-devShell-for {
              package =
                packages.pythoneda-realm-unveilingpartner-application-python38;
              python = pkgs.python38;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python38;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python38;
              inherit archRole layer nixpkgsRelease org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-realm-unveilingpartner-application-python39;
              python = pkgs.python39;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python39;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python39;
              inherit archRole layer nixpkgsRelease org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-raw-python39 =
            shared.raw-devShell-for {
              package =
                packages.pythoneda-realm-unveilingpartner-application-python39;
              python = pkgs.python39;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python39;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python39;
              inherit archRole layer nixpkgsRelease org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-realm-unveilingpartner-application-python310;
              python = pkgs.python310;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python310;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python310;
              inherit archRole layer nixpkgsRelease org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-raw-python310 =
            shared.raw-devShell-for {
              package =
                packages.pythoneda-realm-unveilingpartner-application-python310;
              python = pkgs.python310;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python310;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python310;
              inherit archRole layer nixpkgsRelease org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-python311 =
            shared.devShell-for {
              package =
                packages.pythoneda-realm-unveilingpartner-application-python311;
              python = pkgs.python311;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python311;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python311;
              inherit archRole layer nixpkgsRelease org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-application-raw-python311 =
            shared.raw-devShell-for {
              package =
                packages.pythoneda-realm-unveilingpartner-application-python311;
              python = pkgs.python311;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python311;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python311;
              inherit archRole layer nixpkgsRelease org pkgs repo space;
            };
        };
        packages = rec {
          default = pythoneda-realm-unveilingpartner-application-default;
          pythoneda-realm-unveilingpartner-application-default =
            pythoneda-realm-unveilingpartner-application-python311;
          pythoneda-realm-unveilingpartner-application-python38 =
            pythoneda-realm-unveilingpartner-application-for {
              python = pkgs.python38;
              pythoneda-realm-unveilingpartner-infrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.packages.${system}.pythoneda-realm-unveilingpartner-infrastructure-python38;
              pythoneda-realm-unveilingpartner-realm =
                pythoneda-realm-unveilingpartner-realm.packages.${system}.pythoneda-realm-unveilingpartner-realm-python38;
              pythoneda-shared-pythoneda-application =
                pythoneda-shared-pythoneda-application.packages.${system}.pythoneda-shared-pythoneda-application-python38;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python38;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python38;
            };
          pythoneda-realm-unveilingpartner-application-python39 =
            pythoneda-realm-unveilingpartner-application-for {
              python = pkgs.python39;
              pythoneda-realm-unveilingpartner-infrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.packages.${system}.pythoneda-realm-unveilingpartner-infrastructure-python39;
              pythoneda-realm-unveilingpartner-realm =
                pythoneda-realm-unveilingpartner-realm.packages.${system}.pythoneda-realm-unveilingpartner-realm-python39;
              pythoneda-shared-pythoneda-application =
                pythoneda-shared-pythoneda-application.packages.${system}.pythoneda-shared-pythoneda-application-python39;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python39;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python39;
            };
          pythoneda-realm-unveilingpartner-application-python310 =
            pythoneda-realm-unveilingpartner-application-for {
              python = pkgs.python310;
              pythoneda-realm-unveilingpartner-infrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.packages.${system}.pythoneda-realm-unveilingpartner-infrastructure-python310;
              pythoneda-realm-unveilingpartner-realm =
                pythoneda-realm-unveilingpartner-realm.packages.${system}.pythoneda-realm-unveilingpartner-realm-python310;
              pythoneda-shared-pythoneda-application =
                pythoneda-shared-pythoneda-application.packages.${system}.pythoneda-shared-pythoneda-application-python310;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python310;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python310;
            };
          pythoneda-realm-unveilingpartner-application-python311 =
            pythoneda-realm-unveilingpartner-application-for {
              python = pkgs.python311;
              pythoneda-realm-unveilingpartner-infrastructure =
                pythoneda-realm-unveilingpartner-infrastructure.packages.${system}.pythoneda-realm-unveilingpartner-infrastructure-python311;
              pythoneda-realm-unveilingpartner-realm =
                pythoneda-realm-unveilingpartner-realm.packages.${system}.pythoneda-realm-unveilingpartner-realm-python311;
              pythoneda-shared-pythoneda-application =
                pythoneda-shared-pythoneda-application.packages.${system}.pythoneda-shared-pythoneda-application-python311;
              pythoneda-shared-pythoneda-banner =
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python311;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python311;
            };
        };
      });
}
