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
      zig
      nodejs_latest
      pnpm
      bun
      deno

      # Security
      keybase
      age
      age-plugin-ledger
      age-plugin-fido2-hmac

      # OCaml Development
      ocaml
      ocamlPackages.dune_3
      ocamlPackages.findlib
      ocamlPackages.ocaml-lsp
      ocamlPackages.utop
      ocamlPackages.odoc
      ocamlPackages.ocamlformat
      ocamlPackages.merlin
      ocamlPackages.core
      ocamlPackages.core_unix
      ocamlPackages.batteries
      ocamlPackages.ppxlib
      ocamlPackages.js_of_ocaml
      ocamlPackages.js_of_ocaml-compiler
      ocamlPackages.lwt
      ocamlPackages.lwt_ppx
      ocamlPackages.yojson
      ocamlPackages.reason
      nodejs_latest # For running JavaScript output from Melange/ReScript
      opam # For managing OCaml environments and installing additional packages
      # Note: To install Melange or ReScript, use:
      # opam install melange
      # npm install rescript

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
      ocaml
      ocaml-top
      ocaml_make
      ocamlformat
      reason
      opam
    ]
    ++ (with nodePackages; [pnpm reason])
    ++ (with ocamlPackages; [ocaml-lsp merlin reason ocaml melange])
    # Tools for Haskell
    ++ [ghc haskell-language-server stack cabal-cli zlib cabal-install hpack]
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
    # Type `<ctrl> + r` to fuzzy search your shell history
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

        # OCaml OPAM configuration
        test -r $HOME/.opam/opam-init/init.zsh && . $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
      '';
    };

    nushell = {
      enable = true;
      extraConfig = ''
        # Common ls aliases and sort them by type and then name
        # Inspired by https://github.com/nushell/nushell/issues/7190
        def lla [...args] { ls -la ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
        def la  [...args] { ls -a  ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
        def ll  [...args] { ls -l  ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
        def l   [...args] { ls     ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }

        # OCaml aliases
        def ocfmt [...args] { ocamlformat ...$args }
        def dune-build [...args] { dune build ...$args }
        def dune-test [...args] { dune test ...$args }
        def dune-exec [prog ...args] { dune exec $prog -- ...$args }
        def dune-clean [] { dune clean }
        def mel-build [...args] { npx melange build ...$args }
        def mel-run [] { node _build/default/src/main.js }
        def res-build [...args] { npx rescript build ...$args }
        def res-start [] { npx rescript build -w }
        def res-clean [] { npx rescript clean }

        # Completions
        # mainly pieced together from https://www.nushell.sh/cookbook/external_completers.html

        # carapce completions https://www.nushell.sh/cookbook/external_completers.html#carapace-completer
        # + fix https://www.nushell.sh/cookbook/external_completers.html#err-unknown-shorthand-flag-using-carapace
        # enable the package and integration bellow
        let carapace_completer = {|spans: list<string>|
          carapace $spans.0 nushell ...$spans
          | from json
          | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
        }
        # some completions are only available through a bridge
        # eg. tailscale
        # https://carapace-sh.github.io/carapace-bin/setup.html#nushell
        $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

        # fish completions https://www.nushell.sh/cookbook/external_completers.html#fish-completer
        let fish_completer = {|spans|
          ${lib.getExe pkgs.fish} --command $'complete "--do-complete=($spans | str join " ")"'
          | $"value(char tab)description(char newline)" + $in
          | from tsv --flexible --no-infer
        }

        # zoxide completions https://www.nushell.sh/cookbook/external_completers.html#zoxide-completer
        let zoxide_completer = {|spans|
            $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
        }

        # multiple completions
        # the default will be carapace, but you can also switch to fish
        # https://www.nushell.sh/cookbook/external_completers.html#alias-completions
        let multiple_completers = {|spans|
          ## alias fixer start https://www.nushell.sh/cookbook/external_completers.html#alias-completions
          let expanded_alias = scope aliases
          | where name == $spans.0
          | get -i 0.expansion

          let spans = if $expanded_alias != null {
            $spans
            | skip 1
            | prepend ($expanded_alias | split row ' ' | take 1)
          } else {
            $spans
          }
          ## alias fixer end

          match $spans.0 {
            __zoxide_z | __zoxide_zi => $zoxide_completer
            _ => $carapace_completer
          } | do $in $spans
        }

        $env.config = {
          show_banner: false,
          completions: {
            case_sensitive: false # case-sensitive completions
            quick: true           # set to false to prevent auto-selecting completions
            partial: true         # set to false to prevent partial filling of the prompt
            algorithm: "fuzzy"    # prefix or fuzzy
            external: {
              # set to false to prevent nushell looking into $env.PATH to find more suggestions
              enable: true
              # set to lower can improve completion performance at the cost of omitting some options
              max_results: 100
              completer: $multiple_completers
            }
          }
        }

        $env.PATH = ($env.PATH |
          split row (char esep) |
          prepend /home/keinsell/.apps |
          prepend /home/keinsell/.local/bin |
          prepend /home/keinsell/.cargo/bin |
          prepend /home/keinsell/.opam/default/bin |
          append /usr/bin/env
        )

        # OCaml environment setup
        if (which opam | is-empty) == false {
          # Initialize OPAM environment variables
          let opam_env = (opam env --set-switch | lines | parse "{name}={value}" | where name != "" | reduce -f {} {|it, acc| $acc | insert $it.name $it.value})

          # Set OCaml environment variables
          $env.OCAML_TOPLEVEL_PATH = ($opam_env | get -i OCAML_TOPLEVEL_PATH)
          $env.CAML_LD_LIBRARY_PATH = ($opam_env | get -i CAML_LD_LIBRARY_PATH)
          $env.OPAM_SWITCH_PREFIX = ($opam_env | get -i OPAM_SWITCH_PREFIX)
        }

        $env.STARSHIP_SHELL = "nu"

        def create_left_prompt [] {
            starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
        }

        # Use nushell functions to define your right and left prompt
        $env.PROMPT_COMMAND = { || create_left_prompt }
        $env.PROMPT_COMMAND_RIGHT = ""

        # The prompt indicators are environmental variables that represent
        # the state of the prompt
        $env.PROMPT_INDICATOR = ""
        $env.PROMPT_INDICATOR_VI_INSERT = ": "
        $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
        $env.PROMPT_MULTILINE_INDICATOR = "::: "
      '';
    };

    carapace.enable = true;
    atuin.enable = true;
    mise.enable = true;
    # Type `z <pat>` to cd to some directory
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

      languages = {
        language-server = {
          nil = {
            command = lib.getExe pkgs.nil;
          };
          nixd = {
            command = lib.getExe pkgs.nixd;
          };
          ocamllsp = {
            command = lib.getExe pkgs.ocamlPackages.ocaml-lsp;
          };

          rescriptranger = {
            command = "npx";
            args = ["@rescript/language-server" "--stdio"];
            config = {
              extensionConfiguration = {
                rescript = {
                  languageServer = {
                    arguments = ["--node-runtime" "node"];
                  };
                };
              };
            };
          };
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            language-servers = ["nil" "nixd"];
            formatter.command = lib.getExe pkgs.alejandra;
          }
          {
            name = "ocaml";
            auto-format = true;
            language-servers = ["ocamllsp"];
            formatter = {
              command = lib.getExe pkgs.ocamlPackages.ocamlformat;
              args = ["--name" "$FILE" "-"];
            };
          }
          {
            name = "reason";
            auto-format = true;
            language-servers = ["ocamllsp"];
          }
          {
            name = "rescript";
            auto-format = true;
            language-servers = ["rescriptranger"];
            formatter = {
              command = "rescript";
              args = ["format"];
            };
          }
        ];
      };

      extraPackages = with pkgs; [
        marksman
        markdown-oxide
        nil
        nixd
        biome
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

    # OCaml aliases
    ocfmt = "ocamlformat";
    dune-build = "dune build";
    dune-test = "dune test";
    dune-exec = "dune exec";
    dune-clean = "dune clean";
    mel-build = "npx melange build";
    mel-run = "node _build/default/src/main.js";
    res-build = "npx rescript build";
    res-start = "npx rescript build -w";
    res-clean = "npx rescript clean";
  };
}
