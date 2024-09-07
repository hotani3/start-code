#!/bin/zsh

# Get -v option value as Python version
while getopts v: OPT
do
  case $OPT in
    v) PYTHON_VERSION=$OPTARG ;;
  esac
done

# If not specified in an arg, set default version
if [ -z "$PYTHON_VERSION" ]; then
  PYTHON_VERSION=$DEFAULT_PYTHON_VERSION
fi

# Validate version number format
assert_version_format $PYTHON_VERSION

package_title='Python'
detect_cmd="pyenv versions | grep -q $PYTHON_VERSION"
version_cmd="pyenv versions | grep -o $PYTHON_VERSION"
install_cmd="pyenv install $PYTHON_VERSION"
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  install $package_title $install_cmd
  detect $package_title $detect_cmd $version_cmd true
fi

# Check if python and pip are available on the current global Python version on pyenv
# This check fails when the version is "system", but Python is not installed on the system
package_title='current global Python'
detect_cmd="python -V >/dev/null 2>&1"
version_cmd='python -V | awk '\''{print $2}'\'''
detect $package_title $detect_cmd $version_cmd false
python_detected=$?

package_title='current global pip'
detect_cmd="pip -V >/dev/null 2>&1"
version_cmd='pip -V | awk '\''{print $2}'\'''
detect $package_title $detect_cmd $version_cmd false
pip_detected=$?

# If python or pip is not available, switch to the installed Python version in pyenv-python.sh
if [ $python_detected -ne 0 ] || [ $pip_detected -ne 0 ]; then
  execute "Switching global Python version to $PYTHON_VERSION on pyenv" \
          "pyenv global $PYTHON_VERSION" "Failed to switch global Python version to $PYTHON_VERSION"
fi
