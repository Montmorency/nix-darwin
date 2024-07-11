#!/usr/bin/env zsh

# Check if the first argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <ssh_alias>"
  exit 1
fi

# Assign the first argument to the ssh_alias variable
ssh_alias=$1
app_home_dir=$2

echo "Building the app..."
if ! nix build --impure .#packages.x86_64-linux.unoptimized-prod-server; then
  echo "Error: Failed to build the Nix package" >&2
  exit 1
fi

# Copy the build result to the remote machine
echo "Copying the build result to the remote machine..."
if ! nix copy --to ssh://${ssh_alias} ./result; then
  echo "Error: Failed to copy the build result" >&2
  exit 1
fi

# symlink the store path to the systemd path alternatively we could force the systemd to reference the repos flake?
if ! ssh ${ssh_alias} "ln -sfT $(readlink -f ./result) ${app_home_dir}"; then
  echo "Error: Failed to symlink result to the app directory." >&2
  exit 1
fi

echo "Build and copy process completed successfully."
