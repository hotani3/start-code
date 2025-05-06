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

# Get -v option value as Ansible version
# Get --python option value as Python version
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v)
      ANSIBLE_VERSION="$2"
      shift 2
      ;;
    --python)
      PYTHON_VERSION="$2"
      shift 2
      ;;
  esac
done

# If not specified in an arg, set default Ansible version
if [ -z "$ANSIBLE_VERSION" ]; then
  ANSIBLE_VERSION=$DEFAULT_ANSIBLE_VERSION
fi

# If not specified in an arg, set default Python version
if [ -z "$PYTHON_VERSION" ]; then
  PYTHON_VERSION=$DEFAULT_PYTHON_VERSION
fi

# Validate version number
assert_ansible_version $ANSIBLE_VERSION
assert_ansible_and_python_version $ANSIBLE_VERSION $PYTHON_VERSION

source ./macos/lib/homebrew.sh
source ./macos/lib/pyenv.sh
source ./macos/lib/pyenv-python.sh

# Save current global Python version
PREV_PYTHON_VERSION=$(pyenv versions --skip-aliases --skip-envs | grep -e '^*' | awk '{print $2}')

execute "Switching Python version to $PYTHON_VERSION" \
        "pyenv global $PYTHON_VERSION" "Failed to switch Python version to $PYTHON_VERSION"

# Enable the ansible command if already installed
if [ -d "$HOME/envs/ansible-$ANSIBLE_VERSION-on-python-$PYTHON_VERSION" ]; then
  source $HOME/envs/ansible-$ANSIBLE_VERSION-on-python-$PYTHON_VERSION/bin/activate
fi

package_title='Ansible'
detect_cmd='ansible --version >/dev/null 2>&1'
version_cmd="ansible --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'"
install_cmd="python3 -m pip install ansible-core==$ANSIBLE_VERSION"
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  # Create a virtual environment and activate it
  python3 -m venv $HOME/envs/ansible-$ANSIBLE_VERSION-on-python-$PYTHON_VERSION
  source $HOME/envs/ansible-$ANSIBLE_VERSION-on-python-$PYTHON_VERSION/bin/activate

  install $package_title $install_cmd
  # Here, exit_flag of detect function should be set to false
  # Continue to the next step regardless of the installation result
  detect $package_title $detect_cmd $version_cmd false

  deactivate
fi

# Switch back to the previous Python version if it was defined
if [ -n "$PREV_PYTHON_VERSION" ] && [ "$PREV_PYTHON_VERSION" != "$PYTHON_VERSION" ]; then
  execute "Switching back Python version to $PREV_PYTHON_VERSION" \
        "pyenv global $PREV_PYTHON_VERSION" "Failed to switch back Python version to $PREV_PYTHON_VERSION"
fi
