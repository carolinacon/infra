{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  # env.GREET = "devenv";
  env = {
    ANSIBLE_PYTHON_INTERPRETER = "python3";
  };

  # https://devenv.sh/packages/
  packages =  with pkgs; [
    git
    curl
    unzip
    jq
    coreutils # for shasum
    glibcLocales
    direnv
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;
  languages = {
    python = {
      uv = {
        enable = true;
      };
    };
  };

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  # scripts.hello.exec = ''
  #   echo hello from $GREET
  # '';
  scripts = {
    t_wrap.exec = ''
      function install_terraform(){
        echo "Didn't find terraform, so installing" >&2
        set -euxo pipefail
        VERSION=1.12.2
        pushd "$(git rev-parse --show-toplevel)/.devenv/bin/" &&
          curl -fsSLOJ "https://releases.hashicorp.com/terraform/''${VERSION}/terraform_''${VERSION}_linux_amd64.zip" &&
          sha256sum --ignore-missing -c <(curl -fsSL "https://releases.hashicorp.com/terraform/''${VERSION}/terraform_''${VERSION}_SHA256SUMS") &&
          unzip terraform_''${VERSION}_linux_amd64.zip terraform
        popd
        set +euxo pipefail
      }
      # get current versions: curl -fsSL https://api.releases.hashicorp.com/v1/releases/terraform | jq '.[].version'
      # display specific version: curl -fsSL https://api.releases.hashicorp.com/v1/releases/terraform | jq '.[] | select(.version == "1.12.2")'
      ls "$(git rev-parse --show-toplevel)/.devenv/bin/terraform" &> /dev/null || install_terraform || exit 1
      "$(git rev-parse --show-toplevel)/.devenv/bin/terraform" ''${@}
    '';
  };

  # enterShell = ''
  #   hello
  #   git --version
  # '';
  enterShell = ''
    export LC_ALL="C.UTF-8"
    eval "$(direnv hook bash)"
    mkdir -p "$(git rev-parse --show-toplevel)/.devenv/bin"
    t_wrap version
    export PATH="$(git rev-parse --show-toplevel)/.devenv/bin/":$PATH
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # # https://devenv.sh/tests/
  # enterTest = ''
  #   echo "Running tests"
  #   git --version | grep --color=auto "${pkgs.git.version}"
  # '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
