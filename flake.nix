{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      #computeWheelUrl =
      # {
      #   pname,
      #   version,
      #   dist ? "py2.py3",
      #   python ? "py2.py3",
      #   abi ? "none",
      #   platform ? "any",
      # }:
      # # Fetch a wheel. By default we fetch an universal wheel.
      # # See https://www.python.org/dev/peps/pep-0427/#file-name-convention for details regarding the optional arguments.
      # "https://files.pythonhosted.org/packages/${dist}/${builtins.substring 0 1 pname}/${pname}/${pname}-${version}-${python}-${abi}-${platform}.whl";
      packages = forAllSystems (
        system:
        with pkgs.${system}.python312Packages;
        let
          inherit (pkgs.${system}) fetchFromGitHub;
        in
        rec {
          lxmf = buildPythonPackage rec {
            pname = "lxmf";
            version = "0.9.4";
            format = "wheel";
            dependencies = [
              rns
            ];
            src = fetchPypi {
              inherit format pname version;
              dist = "py3";
              python = "py3";
              hash = "sha256-ct66zoAd7IsshB7jR1/ONrewDqjiWYIuFVV9393B5GQ=";
            };

            meta = {
              description = "A simple and flexible messaging format and delivery protocol that allows a wide variety of implementations, while using as little bandwidth as possible";
              homepage = "https://github.com/markqvist/lxmf";
              # TODO
              # license = lib.licenses.cc-by-nc-sa-40;
            };
          };
          lxst = buildPythonPackage rec {
            pname = "lxst";
            version = "0.4.6";
            format = "wheel";
            dependencies = [
              cffi
              lxmf
              numpy
              pycodec2
              rns
            ];
            src = fetchPypi {
              inherit format pname version;
              dist = "py3";
              python = "py3";
              hash = "sha256-SbPAPpPBjhPIOtBMOfujhtoXSsZJuREkxpWkyvr3j1g=";
            };

            meta = {
              description = "A simple and flexible real-time streaming format and delivery protocol that allows a wide variety of implementations, while using as little bandwidth as possible";
              homepage = "https://git.unsigned.io/markqvist/lxst";
              # TODO
              # license = lib.licenses.cc-by-nc-sa-40;
            };
          };
          numpy = pkgs.${system}.python312Packages.numpy.overrideAttrs (prevAttrs: rec {
            version = "2.3.5";
            src = fetchFromGitHub {
              owner = "numpy";
              repo = "numpy";
              tag = "v${version}";
              fetchSubmodules = true;
              hash = "sha256-CMgJmsjPLgMCWN2iJk0OzcKIlnRRcayrTAns51S4B6k=";
            };
          });
          pycodec2 = buildPythonPackage rec {
            pname = "pycodec2";
            version = "ba67d50883ca7e8885618c741a9f80a9ac1d9a7f";
            pyproject = true;
            buildInputs = with pkgs.${system}; [
              codec2
            ];
            build-system = [ setuptools ];
            dependencies = [
              cython
              numpy
            ];
            src = fetchFromGitHub {
              owner = "gregorias";
              repo = "pycodec2";
              rev = "ba67d50883ca7e8885618c741a9f80a9ac1d9a7f";
              hash = "sha256-gt/e2fmGffwlhSdUbg1ireCtQJ0xju+5u+QyttTZDog=";
            };

            meta = {
              description = "Cython wrapper for Codec 2";
              homepage = "https://github.com/gregorias/pycodec2";
              # TODO
              # license = lib.licenses.cc-by-nc-sa-40;
            };
          };
          pyobjus = buildPythonPackage rec {
            pname = "pyobjus";
            version = "1.2.4";
            pyproject = true;
            buildInputs = with pkgs.${system}; [
              libffi
            ];
            build-system = [ setuptools ];
            dependencies = [
              cython
            ];
            src = fetchPypi {
              inherit pname version;
              hash = "sha256-SHcQH/O3C3/SsSsoeKsj7kiAGM5hPxKUi1j/TH42M4g=";
            };

            meta = {
              description = "Access Objective-C classes from Python";
              homepage = "https://github.com/kivy/pyobjus";
              # TODO
              # license = lib.licenses.cc-by-nc-sa-40;
            };
          };
          rns = buildPythonPackage rec {
            pname = "rns";
            version = "1.1.4";
            format = "wheel";
            dependencies = [
              cryptography
              pyserial
            ];
            src = fetchPypi {
              inherit format pname version;
              dist = "py3";
              python = "py3";
              hash = "sha256-sqF1q9ZNFYHdBYIGgyeT2/cFOjBMgZ/4vBQ6ecSct0c=";
            };

            meta = {
              description = "Cryptography-based networking stack for building local and wide-area networks with readily available hardware";
              homepage = "https://reticulum.network/";
              # TODO
              # license = lib.licenses.cc-by-nc-sa-40;
            };
          };

          sbapp = buildPythonApplication rec {
            pname = "sbapp";
            version = "1.8.2";
            format = "wheel";
            dependencies = [
              lxmf
              lxst
              kivy
              numpy
              pillow
              mistune
              qrcode
              materialyoucolor
              beautifulsoup4
              pycodec2
              pyobjus
              rns
            ];

            preFixup = ''
              patch --strip 1 --unified --directory $out/lib/python3.12/site-packages --input ${./fix-string-type.patch}
            '';
            src = fetchPypi {
              inherit format pname version;
              dist = "py3";
              python = "py3";
              hash = "sha256-gG53OLgphnXW44BTaPQmL9HJu1oCLZubqrJ4uOL9bKI=";
            };

            meta = {
              description = "Extensible Reticulum LXMF messaging and LXST telephony client";
              homepage = "https://github.com/markqvist/Sideband";
              # TODO
              # license = lib.licenses.cc-by-nc-sa-40;
              mainProgram = "sideband";
            };
          };
        }
      );
    };
}
