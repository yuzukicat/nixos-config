# To-dos:

# Suggestions when you want to build NixOS livecd ISO image on non-Nixos Linux distribuction, e.g. Arch Linux, using Nix Flake   

1. Enable experimental-features.   

```
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

And restart ``nix-daemon.service`` using ``sudo systemctl restart nix-daemon``.   

[Flakes](https://nixos.wiki/wiki/Flakes)   

2. ``nix-env --install`` might be required.   

[Nix | Arch](https://wiki.archlinux.org/title/Nix)

# Error handling for building nixos using nix flake   

## Nix flakes /nix/store/***-source no such file or directory   

1. Make sure you are using bash.   

> Unfortunatly nix assumes that the NIX_BUILD_SHELL is a bash variant and passes bash specific arguments to the shell.   

[zsh in nix-shell](https://github.com/chisui/zsh-nix-shell)   

2. Make sure you did ``git add flake.nix`` if you newly cloned a git repo or similar.   

[Custom live media with Nix flakes](https://hoverbear.org/blog/nix-flake-live-media/)   

## Segmentation fault when building ISO image with nixFlakes   

```
GC_DONT_GC=1 nix build ...
```

[Nix | Issue #4246](https://github.com/NixOS/nix/issues/4246)   

## Error: experimental Nix feature ‘auto-allocate-uids’ is disabled, use '--extra-experimental-features auto-allocate-uids' when using ``nixos-install --flake .#example`` to install NixOS from an ISO iamge   

The correct command should be: e.g.   

```
nixos-install --root /mnt --flake .#example --option extra-experimental-features auto-allocate-uids --option extra-experimental-features cgroups
```