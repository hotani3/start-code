#!/bin/zsh
readonly SCRIPT_NAME=$(basename $0)

# exit if not in start-code directory
if [ $(basename $(pwd)) != "start-code" ] || [ ! -d macos ]; then
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] $SCRIPT_NAME: Please run this script in the "\""start-code"\"" directory" >&2
  exit 1
fi

source ./macos/lib/constants.sh
source ./macos/lib/functions.sh

timestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "[$timestamp] $SCRIPT_NAME $SCRIPT_VERSION: Running on macOS $MACOS_VERSION ($CPU_ARCH)"

source ./macos/lib/homebrew.sh
source ./macos/lib/pyenv.sh
source ./macos/lib/pyenv-python.sh

# save current global Python version
PREV_PYTHON_VERSION=$(pyenv versions --skip-aliases --skip-envs | grep -e '^*' | awk '{print $2}')

execute "Switching to Python $PYTHON_VERSION" \
        "pyenv global $PYTHON_VERSION" "Failed to switch Python version to $PYTHON_VERSION"

package_title='Pipenv'
detect_cmd='pipenv --version >/dev/null 2>&1'
version_cmd='pipenv --version | awk '\''{print $3}'\'''
install_cmd='pip install pipenv'
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  install $package_title $install_cmd
  # here, exit_flag of detect function should be set to false
  # continue to the next step regardless of the installation result
  detect $package_title $detect_cmd $version_cmd false
fi

# switch back to the previous Python version if it was defined
if [ -n "$PREV_PYTHON_VERSION" ] && [ "$PREV_PYTHON_VERSION" != "$PYTHON_VERSION" ] ; then
  execute "Switching back to Python $PREV_PYTHON_VERSION" \
        "pyenv global $PREV_PYTHON_VERSION" "Failed to switch back Python version to $PREV_PYTHON_VERSION"

  package_title='Python'
  detect_cmd="python -V >/dev/null 2>&1"
  version_cmd='python -V | awk '\''{print $2}'\'''
  detect $package_title $detect_cmd $version_cmd true
  if [ $? -eq 0 ] ; then
    package_title='Pipenv'
    detect_cmd='pipenv --version >/dev/null 2>&1'
    version_cmd='pipenv --version | awk '\''{print $3}'\'''
    install_cmd='pip install pipenv'
    detect $package_title $detect_cmd $version_cmd false
    if [ $? -ne 0 ] ; then
      install $package_title $install_cmd
      detect $package_title $detect_cmd $version_cmd true
    fi
  fi
fi
