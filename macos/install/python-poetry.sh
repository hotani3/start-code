#!/bin/zsh
readonly SCRIPT_NAME=$(basename $0)

# Exit if not in start-code directory
if [ ! -d "macos/install" ] || [ ! -d "macos/lib" ]; then
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] ERROR $SCRIPT_NAME: Please run this script in the "\""start-code"\"" directory" >&2
  exit 1
fi

source ./macos/lib/constants.sh
source ./macos/lib/functions.sh

timestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "[$timestamp] INFO $SCRIPT_NAME $SCRIPT_VERSION: Running on macOS $MACOS_VERSION ($CPU_ARCH)"

source ./macos/lib/homebrew.sh
source ./macos/lib/pyenv.sh
source ./macos/lib/pyenv-python.sh

# Save current global Python version
PREV_PYTHON_VERSION=$(pyenv versions --skip-aliases --skip-envs | grep -e '^*' | awk '{print $2}')

execute "Switching Python version to $PYTHON_VERSION" \
        "pyenv global $PYTHON_VERSION" "Failed to switch Python version to $PYTHON_VERSION"

# Enable the poetry command if already installed
if [ -f ~/.zshrc ]; then
  source ~/.zshrc
fi

package_title='Poetry'
detect_cmd='poetry --version >/dev/null 2>&1'
version_cmd="poetry --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'"
install_cmd='curl -sSL https://install.python-poetry.org | python3 -'
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  install $package_title $install_cmd

  # $HOME/.local/bin is a common path for user-installed programs
  # Therefore add it to the PATH only if not exists
  echo $PATH | grep -q "$HOME/.local/bin"
  if [ $? -ne 0 ]; then
    echo "# Poetry" >> ~/.zshrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    sync
    source ~/.zshrc
  fi

  # Here, exit_flag of detect function should be set to false
  # Continue to the next step regardless of the installation result
  detect $package_title $detect_cmd $version_cmd false
fi

# Switch back to the previous Python version if it was defined
if [ -n "$PREV_PYTHON_VERSION" ] && [ "$PREV_PYTHON_VERSION" != "$PYTHON_VERSION" ]; then
  execute "Switching back Python version to $PREV_PYTHON_VERSION" \
        "pyenv global $PREV_PYTHON_VERSION" "Failed to switch back Python version to $PREV_PYTHON_VERSION"
fi
