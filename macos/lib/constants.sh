#!/bin/zsh
readonly SCRIPT_VERSION="1.0.2"

readonly DEFAULT_PYTHON_VERSION="3.12.7"
readonly CPU_ARCH=$(uname -m)
readonly MACOS_VERSION=$(sw_vers -productVersion)
