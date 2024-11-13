#!/bin/zsh
readonly SCRIPT_VERSION="1.1.0"
readonly NVM_VERSION="0.40.1"

readonly DEFAULT_PYTHON_VERSION="3.12.7"
readonly DEFAULT_NODE_VERSION="22.11.0"

readonly CPU_ARCH=$(uname -m)
readonly MACOS_VERSION=$(sw_vers -productVersion)
