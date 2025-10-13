#!/bin/zsh
readonly SCRIPT_VERSION="1.2.1"
readonly NVM_VERSION="0.40.3"

readonly DEFAULT_NODE_VERSION="22.20.0"
readonly DEFAULT_PYTHON_VERSION="3.12.12"
readonly DEFAULT_ANSIBLE_VERSION="2.18.10"

readonly CPU_ARCH=$(uname -m)
readonly MACOS_VERSION=$(sw_vers -productVersion)
