Mon  8 Jul 2024 13:12:37 IST
Back up your /etc/nix/nix.conf


Creating new darwin machine image:
```
nix run nix-darwin -- switch --flake .#Enrico
```

Change Enrico to your machine's hostName.


To Access linux builder

I have permissions at 600

```
sudo ssh -i /etc/nix/builder_ed25519 builder@linux-builder
```
