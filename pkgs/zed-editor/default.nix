{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "zed-editor";
  powner = "zed-industries";
  prepo = "zed";
  version = "0.126.3";

  src = fetchFromGitHub {
    owner = powner;
    repo = prepo;
    rev = "7ee7ef5f33f884d480c2884f5fc07691f02770c4";
    hash = "sha256-CD+urN+iN3T3GrIBdagCOrS0nZy3GxGpUD4mhGH/lBs=";
  };

  cargoLock = {
    lockFile = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/${powner}/${prepo}/v${version}/Cargo.lock";
      sha256 = "07p1a2rl2yas5kcsdkgfhbhj36a5zd35k9fk84b84079f9m2qzrv";
    };
    outputHashes = {
      "async-pipe-0.1.3" = lib.fakeSha256;
      "blade-graphics-0.3.0" = lib.fakeSha256;
      "bromberg_sl2-0.6.0" = lib.fakeSha256;
      "font-kit-0.11.0" = lib.fakeSha256;
      "lsp-types-0.94.1" = lib.fakeSha256;
      "nvim-rs-0.6.0-pre" = lib.fakeSha256;
      "pathfinder_simd-0.5.2" = lib.fakeSha256;
      "procinfo-0.1.0" = lib.fakeSha256;
      "taffy-0.3.11" = lib.fakeSha256;
      "tree-sitter-0.20.100" = lib.fakeSha256;
      "tree-sitter-astro-0.0.1" = lib.fakeSha256;
      "tree-sitter-bash-0.20.4" = lib.fakeSha256;
      "tree-sitter-c-sharp-0.20.0" = lib.fakeSha256;
      "tree-sitter-clojure-0.0.9" = lib.fakeSha256;
      "tree-sitter-cpp-0.20.0" = lib.fakeSha256;
      "tree-sitter-css-0.19.0" = lib.fakeSha256;
      "tree-sitter-dart-0.0.1" = lib.fakeSha256;
      "tree-sitter-dockerfile-0.1.0" = lib.fakeSha256;
      "tree-sitter-elixir-0.1.0" = lib.fakeSha256;
      "tree-sitter-elm-5.6.4" = lib.fakeSha256;
      "tree-sitter-gitcommit-0.3.3" = lib.fakeSha256;
      "tree-sitter-gleam-0.34.0" = lib.fakeSha256;
      "tree-sitter-glsl-0.1.4" = lib.fakeSha256;
      "tree-sitter-go-0.19.1" = lib.fakeSha256;
      "tree-sitter-gomod-1.0.2" = lib.fakeSha256;
      "tree-sitter-gowork-0.0.1" = lib.fakeSha256;
      "tree-sitter-haskell-0.14.0" = lib.fakeSha256;
      "tree-sitter-hcl-0.0.1" = lib.fakeSha256;
      "tree-sitter-heex-0.0.1" = lib.fakeSha256;
      "tree-sitter-json-0.20.0" = lib.fakeSha256;
      "tree-sitter-markdown-0.0.1" = lib.fakeSha256;
      "tree-sitter-nix-0.0.1" = lib.fakeSha256;
      "tree-sitter-nu-0.0.1" = lib.fakeSha256;
      "tree-sitter-ocaml-0.20.4" = lib.fakeSha256;
      "tree-sitter-prisma-io-1.4.0" = lib.fakeSha256;
      "tree-sitter-proto-0.0.2" = lib.fakeSha256;
      "tree-sitter-purescript-0.1.0" = lib.fakeSha256;
      "tree-sitter-racket-0.0.1" = lib.fakeSha256;
      "tree-sitter-scheme-0.2.0" = lib.fakeSha256;
      "tree-sitter-svelte-0.10.2" = lib.fakeSha256;
      "tree-sitter-toml-0.5.1" = lib.fakeSha256;
      "tree-sitter-typescript-0.20.2" = lib.fakeSha256;
      "tree-sitter-uiua-0.10.0" = lib.fakeSha256;
      "tree-sitter-vue-0.0.1" = lib.fakeSha256;
      "tree-sitter-yaml-0.0.1" = lib.fakeSha256;
      "tree-sitter-zig-0.0.1" = lib.fakeSha256;
    };
  };

  meta = with lib; {
    description = "Zed is a high-performance, multiplayer code editor from the creators of Atom and Tree-sitter.";
    homepage = "https://zed.dev/";
    license = licenses.gpl3;
    maintainers = [];
  };
}
