#!/bin/zsh

package_title='OpenSSL'
detect_cmd='brew list --versions openssl@3 >/dev/null 2>&1'
version_cmd='brew list --versions openssl@3 | awk '\''{print $2}'\'''
install_cmd='HOMEBREW_NO_INSTALL_CLEANUP=1 brew install openssl@3'
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  install $package_title $install_cmd
  detect $package_title $detect_cmd $version_cmd true
fi

package_title='XZ Utils'
detect_cmd='brew list --versions xz >/dev/null 2>&1'
version_cmd='brew list --versions xz | awk '\''{print $2}'\'''
install_cmd='HOMEBREW_NO_INSTALL_CLEANUP=1 brew install xz'
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  install $package_title $install_cmd
  detect $package_title $detect_cmd $version_cmd true
fi

package_title='pyenv'
detect_cmd='pyenv -v >/dev/null 2>&1'
version_cmd='pyenv -v | awk '\''{print $2}'\'''
install_cmd='HOMEBREW_NO_INSTALL_CLEANUP=1 brew install pyenv'
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  install $package_title $install_cmd

  echo "# pyenv" >> ~/.zshrc
  if [ $CPU_ARCH = "arm64" ]; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
  else
    echo 'export PYENV_ROOT="$HOME/.pyenv_x86"' >> ~/.zshrc
  fi
  echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
  sync
  source ~/.zshrc

  detect $package_title $detect_cmd $version_cmd true
else
  execute "Updating pyenv..." \
          "brew update && HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade pyenv" "Failed to update pyenv"
fi
