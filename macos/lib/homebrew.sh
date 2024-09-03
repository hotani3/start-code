#!/bin/zsh

package_title='Homebrew'
detect_cmd='brew -v >/dev/null 2>&1'
version_cmd='brew -v | head -n 1 | awk '\''{print $2}'\'''
install_cmd='NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  execute "Checking user's password..." \
          "sudo -v" "Failed to check user's password"

  install $package_title $install_cmd

  echo "# Homebrew" >> ~/.zprofile
  if [ $CPU_ARCH = "arm64" ]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
  fi
  sync
  source ~/.zprofile

  detect $package_title $detect_cmd $version_cmd true
fi
