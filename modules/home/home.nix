{
  pkgs,
  config,
  lib,
  ...
}: {
  # Garbage collect the Nix store
  nix.gc.frequency = "hourly";
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 15d";

  # Nix packages to install to $HOME
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs;
    [
      # Base
      coreutils-full
      findutils
      tree
      unzip
      wget
      zstd
      starship

      # Build and compilation tools
      sccache
      ripgrep
      fd
      sd
      tree
      gnumake
      just

      # Nix dev
      devenv
      cachix
      nixd
      nil
      statix
      deadnix
      alejandra
      nh
      nix-info
      nixpkgs-fmt
      comma
      nix-direnv
      nodejs_latest
      typescript

      # Knowledge-base Management
      markdown-oxide
      marksman
      glow

      # On ubuntu, we need this less for `man home-configuration.nix`'s pager to
      # work.
      less
      rustup
      nodejs_latest
      pnpm
      bun
      deno

      # Security
      keybase
      age
      age-plugin-ledger
      age-plugin-fido2-hmac
      nodejs_latest

      # TUIs
      lazyjj
      lazydocker

      # There is a one cool bitmap font called "eldur" however,
      # i could not find package with it.
      # https://github.com/molarmanful/eldur
      # https://github.com/javierbyte/brutalita
      # ---
      noto-fonts
      noto-fonts-emoji
      noto-fonts-extra
      fira-code
      fira-code-symbols
      font-awesome
      departure-mono
      (nerdfonts.override {
        fonts = [
          "NerdFontsSymbolsOnly"
          "Hack"
        ];
      })

      # Scientifica seems to be a most detailed
      # and supported one, there are also other
      # options but this feel in category of
      # "it's enough".
      # https://github.com/oppiliappan/scientifica
      scientifica

      # Cozette also seems to be really pretty
      # option without italics of scientifica which
      # are pretty annoying most of the time.
      # Cozette overall is cleaner than scientifica
      cozette

      # Other bintmas that took my atention
      # zpix-pixel-font # too "slim"
      tamzen

      # Siji is a font containtaining glyphs
      # Should not be used directly
      # https://github.com/stark/siji
      # siji

      # Monospace Fonts
      commit-mono
      jetbrains-mono
      cargo-autoinherit
      monaspace
      departure-mono
      dejavu_fonts
      powerline-fonts
      yt-dlp
      cargo-binstall
      git-credential-manager
      spago
    ]
    # --- Node.js & TypeScript ---
    ++ (with nodePackages; [pnpm reason])
    # --- OCaml ---
    # ++ (with ocamlPackages; [ocaml-lsp merlin reason ocaml melange])
    # --- Haskell ---
    # ++ []
    # --- MacOS ---
    ++ (
      if pkgs.stdenv.isDarwin
      then (with pkgs.darwin.apple_sdk.frameworks; [CoreServices Foundation Security])
      else []
    );

  home.file = {
    "${config.xdg.configHome}/ghostty/config".source = ../../dotfiles/ghostly.toml;
    ".cargo/config.toml".source = ../../dotfiles/cargo.toml;
  };

  programs = {
    bat.enable = true;
    fzf.enable = true;
    jq.enable = true;
    jujutsu.enable = true;
    home-manager.enable = true;
    browserpass.enable = true;

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      envExtra = ''
        eval "$(mise activate zsh)"
        export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
      '';
    };

    carapace.enable = true;
    atuin.enable = true;
    mise.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    nix-index.enableZshIntegration = true;
    mise.enableZshIntegration = true;

    # https://nixos.asia/en/direnv
    direnv = {
      enable = true;
      silent = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
      config.global = {
        # Make direnv messages less verbose
        hide_env_diff = true;
        disable_stdin = true;
        load_dotenv = true;
        strict_env = true;
      };
    };

    zellij = {
      enable = true;
      enableZshIntegration = false;
      enableBashIntegration = false;
      settings = {
        simplified_ui = true;
        theme = "catppuccin-mocha";
        on_force_close = "quit";
        default_layout = "compact";
        ui = {
          pane_frames = {
            rounded_corners = true;
            hide_session_name = true;
          };
        };
      };
    };

    thefuck.enable = true;
    broot.enable = true;
    eza.enable = true;
    tealdeer.enable = true;

    git = {
      enable = true;
      userName = "keinsell";
      userEmail = "keinsell@protonmail.com";
      ignores = ["*~" "*.swp" "node_modules" ".direnv" ".cache" ".DS_Store"];

      aliases = {
        ci = "commit";
      };

      iniContent = {
        # Performance optimalization with
        # usage of fsmonitor which do not seem
        # to be enabled by default.
        # https://github.blog/engineering/infrastructure/improve-git-monorepo-performance-with-a-file-system-monitor/
        core.untrackedCache = true;
        core.fsmonitor = "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";
        branch.sort = "-committerdate";
        rerere.enabled = true;
        push.autoSetupRemote = true;
        pull.rebase = true;
        fetch.fsckObjects = true;
        index.threads = true;
        push = {
          # Make `git push` push relevant annotated tags when pushing branches out.
          followTags = true;
        };
      };

      signing = {
        signByDefault = false;
        # Signing key was generated at 01/01/2025 and replaced older one which was used
        # Key itself is available on keyboase and can be imported to local machine using
        # keybase pgp pull-private "73D2E5DFD6CC2BD08C6822E45B8600D62E632A5A"
        # gpg --import <key-file>
        key = "73D2E5DFD6CC2BD08C6822E45B8600D62E632A5A";
        # TODO: Implement secret management mechanism which would allow for key persistance
        # in repository, nix-sops and usage of age should be considerable option for this
        # purpose.
      };

      difftastic = {
        enable = true;
        display = "side-by-side";
      };

      extraConfig = {
        init.defaultBranch = "trunk";
        credential = {
          # For macOS: Use Git Credential Manager with keychain storage
          # For Linux: Use 'store' first (plain text file), then 'cache' (in-memory)
          # https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage
          # https://git-scm.com/docs/git-credential-store
          helper =
            if pkgs.stdenv.isDarwin
            then [
              "${pkgs.git-credential-manager}/bin/git-credential-manager"
            ]
            else [
              "store" # Plain text storage
              "cache --timeout=604800" # In-memory cache with 7-day timeout
            ];

          # For macOS only - used with Git Credential Manager
          credentialStore =
            if pkgs.stdenv.isDarwin
            then "keychain"
            else "";
        };

        filter.lfs.clean = "${pkgs.git-lfs}/bin/git-lfs clean -- %f";
        filter.lfs.smudge = "${pkgs.git-lfs}/bin/git-lfs smudge -- %f";
        filter.lfs.process = "${pkgs.git-lfs}/bin/git-lfs filter-process";
        filter.lfs.required = true;
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          nerdFontsVersion = 3;
          lightTheme = false;
          filterMode = "fuzzy";
        };
        git = {
          paging = {
            colorArg = "always";
            useConfig = true;
            externalDiffCommand = "${lib.getExe pkgs.difftastic} --color=always";
          };
        };
      };
    };

    # zed-editor = {
    #   enable = false;

    #   # https://github.com/zed-industries/extensions/tree/main/extensions
    #   extensions = [
    #     "just"
    #     "toml"
    #     "nix"
    #     "kdl"
    #     "ansible"
    #     "cargo-appraiser"
    #     "cargo-tom"
    #     "cairo"
    #     "catppuccin-blur"
    #     "cue"
    #     "docker-compose"
    #     "earthfile"
    #     "env"
    #     "flatbuffers"
    #     "gleam"
    #     "graphql"
    #     "graphviz"
    #     "ini"
    #     "jsonnet"
    #     "log"
    #     "make"
    #     "superhtml"
    #     "typst"
    #   ];

    #   userSettings = {
    #     vim_mode = false;
    #     base_keymap = "VSCode";
    #     soft_wrap = "editor_width";
    #     tab_size = 2;
    #     theme = {
    #       dark = "Catppuccin Mocha";
    #       light = "macOS Classic Light";
    #     };

    #     load_direnv = "shell_hook";

    #     languages.Nix = {
    #       language_servers = ["nixd" "!nil"]; # Force use of nixd over nil
    #       formatter = lib.getExe pkgs.alejandra;
    #     };

    #     lsp = let
    #       useDirenv = {binary.path_lookup = true;};
    #     in {
    #       haskell = useDirenv;
    #       rust_analyzer = useDirenv;
    #       nixd = {
    #         binary.path = lib.getExe pkgs.nixd;
    #         binary.path_lookup = true;
    #       };
    #       nil.formatting.command = lib.getExe pkgs.alejandra;
    #     };

    #     buffer_font_family = "Scientifica";
    #     ui_font_size = 16;
    #     ui_font_family = "Scientifica";
    #     buffer_font_size = 14;

    #     outline_panel = {
    #       dock = "left";
    #     };
    #     project_panel = {
    #       dock = "left";
    #     };
    #     ssh_connections = [
    #       {
    #         host = "192.168.1.124";
    #         projects = ["~/src/server"];
    #         upload_binary_over_ssh = true;
    #       }
    #     ];
    #   };
    # };

    helix = {
      enable = true;

      settings = {
        theme = "catppuccin_mocha";
        editor = {
          auto-save = true;
          auto-completion = true;
          color-modes = true;
          line-number = "relative";
          completion-trigger-len = 0;
          mouse = false;
          true-color = true;
          cursorline = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          soft-wrap.enable = true;
          lsp = {
            auto-signature-help = true;
            display-inlay-hints = true;
            display-messages = true;
            enable = true;
            snippets = true;
          };
        };
      };

      # languages = {
      #   language-server = {
      #     nil = {
      #       command = lib.getExe pkgs.nil;
      #     };
      #     nixd = {
      #       command = lib.getExe pkgs.nixd;
      #     };
      #     ocamllsp = {
      #       command = lib.getExe pkgs.ocamlPackages.ocaml-lsp;
      #     };
      #   };

      #   language = [
      #     {
      #       name = "nix";
      #       auto-format = true;
      #       language-servers = ["nil" "nixd"];
      #       formatter.command = lib.getExe pkgs.alejandra;
      #     }
      #   ];
      # };

      extraPackages = with pkgs; [
        marksman
        markdown-oxide
        nil
        nixd
        biome
        haskell-language-server
        rust-analyzer-unwrapped
        ocamlPackages.ocaml-lsp
      ];
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "Departure Mono"
        "cozette"
        "scientifica"
        "0xProto"
        "Commit Mono"
      ];
      # TODO(https://github.com/NixOS/nixpkgs/issues/312826): Migrate into Fluent Emoji
      emoji = ["JoyPixels"];
    };
  };

  home.shellAliases = {
    zj = "zellij";
    lg = "lazygit";
  };
}
