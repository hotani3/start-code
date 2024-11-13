#!/bin/zsh

function assert_version_format() {
  local version="$1"
  local timestamp=""

  if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] ERROR $SCRIPT_NAME: Invalid version format: $version" >&2
    exit 1
  fi
}

# Validate Node.js version number or alias format
# nvm can accept a format like "stable" or "lts/*" or "lts/jod" or "22" or "22.11" or "22.11.0"
function assert_node_version_alias() {
  local version="$1"
  local timestamp=""

  # Refs: https://qiita.com/ko1nksm/items/3d1fd784611620b1bea5
  if [[ ! $version =~ (stable|lts/[*]|lts/iron|lts/jod) ]] && [[ ! $version =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] ERROR $SCRIPT_NAME: Invalid version format: $version" >&2
    exit 1
  fi
}

# Resolve Node.js version number from alias using "nvm ls-remote"
function resolve_node_version() {
  local alias="$1"
  local version="$DEFAULT_NODE_VERSION"

  if [ $alias = "stable" ]; then
    version=$(nvm ls-remote --no-colors | tail -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  elif [[ $alias =~ (lts/[*]|lts/iron|lts/jod) ]] || [[ $alias =~ ^[0-9]+(\.[0-9]+){0,1}$ ]]; then
    version=$(nvm ls-remote --no-colors "$alias" | tail -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  else
    version="$alias"
  fi

  echo $version
}

function execute() {
  local start_msg="$1"
  local cmd="$2"
  local error_msg="$3"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

  echo "[$timestamp] INFO $SCRIPT_NAME: $start_msg"
  eval "$cmd"
  local result=$?

  if [ $result -eq 0 ]; then
    return 0
  else
    echo "[$timestamp] ERROR $SCRIPT_NAME: $error_msg" >&2
    exit 1
  fi
}

function detect() {
  local package_title="$1"
  local detect_cmd="$2"
  local version_cmd="$3"
  local exit_flag="$4"
  local timestamp=""
  local version=""

  eval "$detect_cmd"
  local result=$?

  if [ $result -eq 0 ]; then
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    version=$(eval $version_cmd)
    echo "[$timestamp] INFO $SCRIPT_NAME: Detected $package_title $version"
    return 0
  else
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    if "$exit_flag" ; then
      echo "[$timestamp] ERROR $SCRIPT_NAME: Failed to detect $package_title" >&2
      exit 1
    else
      echo "[$timestamp] WARN $SCRIPT_NAME: Failed to detect $package_title"
      return 1
    fi
  fi
}

function install() {
  local package_title="$1"
  local install_cmd="$2"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

  echo "[$timestamp] INFO $SCRIPT_NAME: Installing $package_title..."
  eval "$install_cmd"
  local result=$?

  if [ $result -eq 0 ]; then
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] INFO $SCRIPT_NAME: Successfully installed $package_title!"
    return 0
  else
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] ERROR $SCRIPT_NAME: Failed to install $package_title" >&2
    exit 1
  fi
}
