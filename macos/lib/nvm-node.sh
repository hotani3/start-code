#!/bin/zsh

# Get -v option value as Node.js version
while getopts v: OPT
do
  case $OPT in
    v) NODE_VERSION=$OPTARG ;;
  esac
done

# If not specified in an arg, set default version
if [ -z "$NODE_VERSION" ]; then
  NODE_VERSION=$DEFAULT_NODE_VERSION
fi

# Validate version number format
assert_version_format $NODE_VERSION

package_title='Node.js'
detect_cmd="nvm ls $NODE_VERSION | grep -q $NODE_VERSION"
version_cmd="nvm ls $NODE_VERSION | grep -o $NODE_VERSION"
install_cmd="nvm install $NODE_VERSION"
detect $package_title $detect_cmd $version_cmd false
if [ $? -ne 0 ]; then
  install $package_title $install_cmd
  detect $package_title $detect_cmd $version_cmd true
fi

# Check if node and npm are available on the current default Node.js version on nvm
# This check fails when the version is "system", but Node.js is not installed on the system
nvm use default >/dev/null 2>&1
package_title='current default Node.js'
detect_cmd="node -v >/dev/null 2>&1"
# Remove the "v" prefix from a version string
version_cmd='node -v | awk '\''{print substr($0, 2)}'\'''
detect $package_title $detect_cmd $version_cmd false
node_detected=$?

package_title='current default npm'
detect_cmd="npm -v >/dev/null 2>&1"
version_cmd='npm -v'
detect $package_title $detect_cmd $version_cmd false
npm_detected=$?

# If node or npm is not available, switch to the installed Node.js version in nvm-node.sh
if [ $node_detected -ne 0 ] || [ $npm_detected -ne 0 ]; then
  execute "Switching default Node.js version to $NODE_VERSION on nvm" \
          "nvm use $NODE_VERSION" "Failed to switch default Node.js version to $NODE_VERSION"
fi
