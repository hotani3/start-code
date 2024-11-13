#!/bin/zsh

# Get -v option value as Node.js version number or alias
while getopts v: OPT
do
  case $OPT in
    v) NODE_VERSION_ALIAS=$OPTARG ;;
  esac
done

# If not specified in an arg, set default version
if [ -z "$NODE_VERSION_ALIAS" ]; then
  NODE_VERSION_ALIAS=$DEFAULT_NODE_VERSION
fi

# Validate version number or alias format
assert_node_version_alias $NODE_VERSION_ALIAS
NODE_VERSION=$(resolve_node_version $NODE_VERSION_ALIAS)

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
default_selected=$?

package_title='current Node.js'
detect_cmd="node -v >/dev/null 2>&1"
# Remove the "v" prefix from a version string
version_cmd='node -v | awk '\''{print substr($0, 2)}'\'''
detect $package_title $detect_cmd $version_cmd false
node_detected=$?

package_title='current npm'
detect_cmd="npm -v >/dev/null 2>&1"
version_cmd='npm -v'
detect $package_title $detect_cmd $version_cmd false
npm_detected=$?

# If node or npm is not available, switch to the installed Node.js version in nvm-node.sh
if [ $default_selected -ne 0 ] || [ $node_detected -ne 0 ] || [ $npm_detected -ne 0 ]; then
  execute "Switching default Node.js version to $NODE_VERSION on nvm" \
          "nvm alias default $NODE_VERSION && nvm use default" "Failed to switch default Node.js version to $NODE_VERSION"
fi
