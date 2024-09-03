#!/bin/zsh

function assert_version_format() {
  local version="$1"
  local timestamp=""

  if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $SCRIPT_NAME: Invalid version format: $version" >&2
    exit 1
  fi
}

function execute() {
  local start_msg="$1"
  local cmd="$2"
  local error_msg="$3"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

  echo "[$timestamp] $SCRIPT_NAME: $start_msg"
  eval "$cmd"
  local result=$?

  if [ $result -eq 0 ]; then
    return 0
  else
    echo "[$timestamp] $SCRIPT_NAME: $error_msg" >&2
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
    echo "[$timestamp] $SCRIPT_NAME: Detected $package_title $version"
    return 0
  else
    if "$exit_flag" ; then
      timestamp=$(date "+%Y-%m-%d %H:%M:%S")
      echo "[$timestamp] $SCRIPT_NAME: Failed to detect $package_title" >&2
      exit 1
    fi
    return 1
  fi
}

function install() {
  local package_title="$1"
  local install_cmd="$2"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

  echo "[$timestamp] $SCRIPT_NAME: Installing $package_title..."
  eval "$install_cmd"
  local result=$?

  if [ $result -eq 0 ]; then
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $SCRIPT_NAME: Successfully installed $package_title!"
    return 0
  else
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $SCRIPT_NAME: Failed to install $package_title" >&2
    exit 1
  fi
}
