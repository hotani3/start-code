#!/bin/zsh

# Enable the nvm command if already installed
source ~/.zshrc

package_title='nvm'
detect_cmd='nvm --version >/dev/null 2>&1'
version_cmd='nvm --version'
# nvm does not support Homebrew installation
install_cmd="curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash"
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  echo "# nvm" >> ~/.zshrc
  install $package_title $install_cmd

  # .zshrc is automatically updated by nvm install script
  sync
  source ~/.zshrc

  detect $package_title $detect_cmd $version_cmd true
fi
