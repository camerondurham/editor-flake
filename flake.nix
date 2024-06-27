{
  description = "u64.cam's neovim flake with custom config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
        config = {allowUnfree = true;};
      };
      dependencies = with pkgs; [
        ripgrep
        lua-language-server
	nodejs_18
      ];
    in rec {
      packages.custom-nvim-flake = pkgs.wrapNeovim pkgs.neovim-unwrapped {
        extraMakeWrapperArgs = ''--prefix PATH : "${pkgs.lib.makeBinPath dependencies}"'';
        configure = {
          viAlias = true;
          vimAlias = true;
          withNodeJs = false;
          withPython3 = false;
          withRuby = false;
          packages.myPlugins = {
            start = with pkgs.vimPlugins; [
              onedarkpro-nvim
              vim-startuptime
              nvim-lspconfig
              nvim-treesitter.withAllGrammars
              oil-nvim # file navigator
              telescope-nvim
            ];
            opt = [];
          };
          customRC =
            ''
              lua << EOF
            ''
            + pkgs.lib.readFile ./init.lua
            + ''
              EOF
            '';
        };
      };
      apps.custom-nvim-flake = flake-utils.lib.mkApp {
        drv = packages.custom-nvim-flake;
        name = "custom-nvim-flake";
        exePath = "/bin/nvim";
      };
      packages.default = packages.custom-nvim-flake;
    });
}
