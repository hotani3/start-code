#!/bin/zsh

# get -v option value as Python version
while getopts v: OPT
do
  case $OPT in
    v) PYTHON_VERSION=$OPTARG ;;
  esac
done

# if not specified in an arg, set default version
if [ -z "$PYTHON_VERSION" ]; then
  PYTHON_VERSION=$DEFAULT_PYTHON_VERSION
fi

# validate version number format
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
