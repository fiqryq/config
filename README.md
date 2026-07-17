# dot-config

Personal dotfiles managed with [Nix Home Manager](https://github.com/nix-community/home-manager).

## Structure

```
dot-config/
├── flake.nix           # Entry point — defines all profiles
├── flake.lock          # Pinned package versions (commit this!)
├── lib/
│   └── mkProfile.nix   # Shared wrapper for all profiles
├── config/             # App configs (symlinked into ~/.config/)
│   ├── nvim/           # LazyVim
│   ├── ghostty/
│   ├── tmux/
│   └── wezterm/
├── templates/          # Placeholder files seeded into $HOME on fresh machines
│   ├── env.local.example          # → ~/.env.local
│   └── ssh-config.local.example   # → ~/.ssh/config.local
├── profiles/
│   ├── personal.nix    # core + shell + git + fnm + php + nginx + extras + ssh
│   ├── work.nix        # core + shell + git + fnm + nginx + devops + ssh
│   └── minimal.nix     # core + shell + git only
└── modules/
    ├── core.nix        # Always-on: tmux, lazygit, bat, eza, fzf, ripgrep, zoxide, starship, direnv
    ├── nvim.nix        # Neovim (unstable) + LazyVim config symlink
    ├── configs.nix     # Symlinks ghostty, tmux, wezterm into ~/.config/
    ├── shell.nix       # zsh + oh-my-zsh + aliases + hms switcher + ~/.env.local seeding
    ├── git.nix         # git config + 1Password SSH signing
    ├── fnm.nix         # fnm (Node version manager) + bun + yarn
    ├── php.nix         # PHP 8.5 + Composer + Laravel installer via php.new (auto-bootstraps)
    ├── ssh.nix         # ssh config: 1Password agent, keep-alives, ~/.ssh/config.local include
    ├── nginx.nix       # mkcert + nginx-add/nginx-remove helpers for local server configs
    ├── devops.nix      # kubectl, helm, gcloud, mkcert, sops, k9s
    └── extras.nix      # ollama, lazydocker, lazysql, cloudflared
```

---

## Bootstrap (new machine)

```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sudo sh -s -- install
# If that fails on macOS, use the .pkg installer: https://dtr.mn/determinate-nix

# 2. Restart shell
exec zsh

# 3. Clone dotfiles
git clone <your-repo-url> ~/dot-config

# 4. Back up any files Home Manager will own
mv ~/.zshrc ~/.zshrc.bak 2>/dev/null
mv ~/.zshenv ~/.zshenv.bak 2>/dev/null
mv ~/.gitconfig ~/.gitconfig.bak 2>/dev/null
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
rm ~/.config/ghostty ~/.config/tmux ~/.config/wezterm 2>/dev/null  # if they're broken symlinks

# 5. Stage files for Nix (flakes require git tracking)
git -C ~/dot-config add .

# 6. Activate your profile
cd ~/dot-config && nix run github:nix-community/home-manager/release-24.11 -- switch --flake .#personal

# 7. Reload shell — hms function is now available
exec zsh
```

The first switch also bootstraps things Nix doesn't manage:

- **PHP, Composer, Laravel installer** — downloaded automatically via php.new
  into `~/.config/herd-lite/bin` (see `modules/php.nix`)
- **`~/.env.local` and `~/.ssh/config.local`** — seeded from `templates/` as
  placeholder skeletons; existing files are never overwritten

Then finish up manually:

```bash
# Fill in machine-local secrets (from 1Password / previous machine)
nvim ~/.env.local          # API tokens, exported env vars
nvim ~/.ssh/config.local   # private SSH hosts (IPs, users)

# Install a Node version (fnm itself comes from Nix, versions don't)
fnm install --lts && fnm default lts-latest
```

---

## Switching profiles

```bash
hms personal   # core + shell + git + node + php + nginx + extras + ssh
hms work       # core + shell + git + node + nginx + devops (kubectl, helm...) + ssh
hms minimal    # core + shell + git only
```

After the first `nix run ...` bootstrap, `hms` is always available as a shell function.

---

## Adding a new package

**1. Find the package name**

Search at https://search.nixos.org/packages or:
```bash
nix search nixpkgs <name>
```

**2. Add it to the right module**

For something you always want:
```nix
# modules/core.nix
home.packages = with pkgs; [
  tmux
  your-new-package   # add here
  ...
];
```

For something only in one profile, add it directly in the profile file:
```nix
# profiles/personal.nix
home.packages = with pkgs; [ some-personal-tool ];
```

For a package that needs the latest version from unstable:
```nix
# any module
home.packages = [ pkgs-unstable.some-package ];
```

**3. Apply**
```bash
hms personal   # or whichever profile you're on
```

---

## Customizing the shell

All zsh config lives in `modules/shell.nix`. You don't edit `~/.zshrc` directly — Home Manager generates it.

### Add an alias

```nix
# modules/shell.nix — programs.zsh.shellAliases
shellAliases = {
  k   = "kubectl";
  cat = "bat";
  # add yours here
};
```

### Add a shell function or inline script

```nix
# modules/shell.nix — programs.zsh.initExtra
initExtra = ''
  # your existing init content...

  function myfunction() {
    echo "hello $1"
  }
'';
```

### Add an environment variable

```nix
# modules/shell.nix or the relevant profile
home.sessionVariables = {
  MY_VAR = "value";
};
```

### Add a PATH entry

```nix
home.sessionPath = [
  "$HOME/my/custom/bin"
];
```

### Profile-specific shell config

Override or extend in a profile instead of the shared module:

```nix
# profiles/work.nix
programs.zsh.shellAliases = {
  kprod = "kubectl --context=production";
};

home.sessionVariables = {
  WORK_ENV = "kitabisa";
};
```

After any change, apply with:
```bash
hms personal   # or your current profile
```

---

## Adding a new app config

**1. Create the config directory**
```bash
mkdir -p ~/dot-config/config/myapp
# add your config files inside it
```

**2. Register it in `modules/configs.nix`**
```nix
xdg.configFile."myapp".source =
  config.lib.file.mkOutOfStoreSymlink "${dotfiles}/myapp";
```

**3. Apply**
```bash
hms personal
```

Home Manager will symlink `~/dot-config/config/myapp` → `~/.config/myapp`.

---

## Adding a new profile

**1. Create `profiles/myprofile.nix`**
```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ../modules/core.nix
    ../modules/nvim.nix
    ../modules/configs.nix
    ../modules/shell.nix
    ../modules/git.nix
    # add or remove modules as needed
  ];

  programs.git.userName  = "Fiqry Choerudin";
  programs.git.userEmail = "your@email.com";
}
```

**2. Register it in `flake.nix`**
```nix
homeConfigurations = {
  personal = mkProfile ./profiles/personal.nix;
  work     = mkProfile ./profiles/work.nix;
  minimal  = mkProfile ./profiles/minimal.nix;
  myprofile = mkProfile ./profiles/myprofile.nix;  # add this
};
```

**3. Add it to the `hms` completions in `modules/shell.nix`**
```bash
local valid_profiles=(personal work minimal myprofile)
```

**4. Apply**
```bash
git -C ~/dot-config add .
hms myprofile
```

---

## Node version management

Node.js is managed by [fnm](https://github.com/Schniz/fnm) (Fast Node Manager). It auto-switches versions based on `.nvmrc` or `.node-version` files when you `cd` into a project.

### Install a Node version

```bash
fnm install --lts          # latest LTS
fnm install 22             # specific major
fnm install 22.14.0        # exact version
```

### Set a global default

```bash
fnm default lts-latest
```

### Pin a project to a specific version

```bash
echo "22" > .nvmrc         # or .node-version
```

fnm will auto-switch when you enter the directory.

### Install pnpm after switching to a new Node version

pnpm is installed globally per Node version via npm:

```bash
npm install -g pnpm@10
```

---

## PHP / Laravel

PHP is **not** installed from nixpkgs — `modules/php.nix` bootstraps static
binaries from [php.new](https://php.new) (Herd Lite) into
`~/.config/herd-lite/bin`: `php` 8.5, `composer`, and the `laravel` installer.

- A home-manager activation hook installs them automatically if missing, so a
  fresh machine gets PHP from the first `hms` run — no manual step.
- PATH and `PHP_INI_SCAN_DIR` are managed by the module; the binaries
  themselves are plain files, not Nix-managed.
- To update PHP, re-run the installer (bump the version in `php.nix` first if
  needed): `/bin/bash -c "$(curl -fsSL https://php.new/install/mac/8.5)"`
- To remove: `~/.config/herd-lite/bin/uninstall_herd_lite` and drop the module
  import.

---

## Upgrading packages

```bash
cd ~/dot-config
nix flake update          # bumps all inputs to latest
hms personal              # rebuild with new versions
git add flake.lock && git commit -m "chore: update flake inputs"
```

To update only one input (e.g. neovim without touching nixpkgs):
```bash
nix flake lock --update-input nixpkgs-unstable
```

---

## Managing environment variables

### Non-sensitive vars — declare in Nix

Add to `home.sessionVariables` in the relevant module or profile:

```nix
# modules/shell.nix or profiles/work.nix
home.sessionVariables = {
  GOPRIVATE = "github.com/your-org";
  KUBECONFIG = "$HOME/.kube/config";
};
```

### Per-project vars — direnv

`direnv` is included in `core.nix`. Create a `.envrc` in any project folder:

```bash
# ~/projects/myapp/.envrc
export DATABASE_URL=postgres://localhost/myapp
export API_URL=http://localhost:3000
```

Then allow it once:
```bash
cd ~/projects/myapp
direnv allow
```

Vars load automatically when you `cd` in and unload when you leave. Add `.envrc` to your global gitignore or commit non-sensitive ones.

### Secrets — `.env.local`

Already wired up in `shell.nix`. This file is machine-local and never
committed (on fresh machines it's seeded from `templates/env.local.example`):

```bash
# ~/.env.local
export GITHUB_TOKEN=ghp_xxx
export OPENAI_API_KEY=sk-xxx
```

> Never put a real secret inside a `.nix` file — everything in the Nix config
> is copied to the world-readable `/nix/store`.

### Private SSH hosts — `~/.ssh/config.local`

`modules/ssh.nix` keeps generic SSH settings (1Password agent, keep-alives) in
the repo and `Include`s `~/.ssh/config.local` for anything machine-private —
server IPs, usernames, per-host keys. Like `.env.local`, it's seeded from
`templates/ssh-config.local.example` and never committed:

```
# ~/.ssh/config.local
Host myserver
  HostName 203.0.113.10
  User ubuntu
```

### Secrets via 1Password CLI (optional)

Pull secrets live instead of storing them in plaintext:

```bash
# ~/.env.local
export GITHUB_TOKEN=$(op read "op://Personal/GitHub Token/credential")
```

Or prefix any command to inject secrets without writing them to disk:
```bash
op run --env-file=.env -- npm run dev
```

---

## What stays in Homebrew

These are NOT managed by Nix — install them manually:

| Tool | Reason |
|------|--------|
| aerospace, yabai, skhd | macOS window managers — not in nixpkgs |
| ghostty, wezterm | Configs managed here; binaries via Homebrew cask |
| caddy, redis, nginx | `brew services` gives launchd integration |
| rustup | Manages its own toolchain |
| nvm | No longer used — replaced by fnm (managed by Nix) |
| orbstack | macOS kernel extension |
