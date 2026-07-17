{ config, pkgs, lib, ... }:

{
  # Seed ~/.ssh/config.local from the placeholder template on a fresh machine;
  # never touches an existing file (it holds real host IPs, kept out of git)
  home.activation.seedSshConfigLocal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.ssh/config.local" ]; then
      mkdir -p "$HOME/.ssh"
      install -m 600 ${../templates/ssh-config.local.example} "$HOME/.ssh/config.local"
      echo "Seeded ~/.ssh/config.local from template — add your private hosts"
    fi
  '';

  programs.ssh = {
    enable = true;

    # config.local holds machine-private host blocks (IPs, users) kept out
    # of the repo — restore it manually when setting up a new machine
    includes = [
      "~/.ssh/config.local"
      "~/.orbstack/ssh/config"
    ];

    matchBlocks = {
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
    };
  };
} 
