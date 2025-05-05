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

# nvm.sh requires the git command in Xcode CLT installed by homebrew.sh
source ./macos/lib/homebrew.sh
source ./macos/lib/nvm.sh

# Get -v option value as Node.js version number or alias
while getopts v: OPT
do
  case $OPT in
    v) NODE_VERSION_ALIAS=$OPTARG ;;
  esac
done
source ./macos/lib/nvm-node.sh
