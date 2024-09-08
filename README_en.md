# start-code
Shell scripts to setup build and runtime environments with version control tools for a starter.  
これからプログラミングを始める方が、素早く開発環境を構築するための、セットアップスクリプト集です。

こちらに、日本語バージョンの[README](./README.md)があります。

## Background
Nowadays, it is common to install multiple versions of development and runtime environments on a single development machine so that multiple applications can be developed in parallel, and switch between them as needed.

Also, external libraries (packages) used by applications should be managed within the local application (project) scope, rather than being installed in the global development or runtime environment.

To achieve these two points, version control tools and package management tools are provided for each language, but it has not always been easy to set them up due to the hassle of installing multiple tools and the frequent occurrence of package dependency issues.

For these reasons, I created a script that allows you to easily set up these tools and start programming quickly.

## System Requirements
Currently, the only platform that has been tested is macOS.

| Platform | CPU Architecture | OS Version |
| :--- | :--- | :--- |
| macOS | x86_64 (Intel), ARM64 (Apple Silicon) | Monterey, Ventura, Sonoma |

## Programming Language
At present, this script is targeted only for Python.

The version control tools and package management tools for each language are as follows. One standard version control tool has been chosen for each language.

| Language | Version Control Tool | Runtime Version | Package Management Tool |
| :--- | :--- | :--- | :--- |
| Python | pyenv | 3.9.x, 3.10.x, 3.11.x, 3.12.x | venv+pip, Pipenv, Poetry |

## How to Execute
First, open the macOS terminal and clone this repository.
```sh
git clone https://github.com/hotani3/start-code.git
```

If the git command is not installed, download the ZIP file from [Releases](https://github.com/hotani3/start-code/releases) and extract it.
```sh
unzip start-code.zip
```

Next, move to the directory that was cloned or extracted from the ZIP.
```sh
cd start-code
```

Then, execute the setup script for each language.  
Be sure to run the script while you are in the "start-code" directory.
```sh
./macos/install/python.sh -v 3.12.6
```

You can specify the development and runtime environment version with the `-v` option.  
If not specified, Python 3.12.6 will be installed.

Immediately after running the script, if you are prompted to enter a password as shown below, please enter your Mac login user's password.

<img src="./images/password-prompt.png" width="800px" alt="Password Prompt" />

Wait a moment, and if the following log is output to the terminal, the Python runtime environment has been successfully installed.
```sh
[2024-09-03 22:57:35] python.sh: Successfully installed Python!
[2024-09-03 22:57:36] python.sh: Detected Python 3.12.6
```

If you want to manage packages with Pipenv or Poetry instead of Python's standard venv+pip, run the following scripts instead of `python.sh`.

#### Pipenv
```sh
./macos/install/python-pipenv.sh -v 3.12.6
```

#### Poetry
```sh
./macos/install/python-poetry.sh -v 3.12.6
```

In the above examples, Python 3.12.6 will be installed, and additionally, Pipenv or Poetry will also be installed.  
In all cases, the `-v` option is for specifying the Python runtime environment version, not the version of Pipenv or Poetry.

Please note that for Pipenv, it will be installed for both the version specified with `-v` and the currently selected version as specified by `pyenv global`.

Finally, open a new window or tab in the terminal, or reload `.zshrc` in the current terminal as shown below to start using the tools.

```sh
source ~/.zshrc
```

## Additional Notes: Packages and Configuration Files Added or Updated
When this script is executed, the following packages will be automatically downloaded and installed as necessary to ensure the operation of version control tools, development and runtime environments, and package management tools.

#### macOS
- Xcode Command Line Tools
- Homebrew
- OpenSSL
- XZ Utils

Additionally, the following configuration files will be automatically updated as necessary to configure environment variables and program execution paths.

#### macOS
- ~/.zprofile
- ~/.zshrc

Therefore, manual installation of packages or manual setting of environment variables required for each tool's operation is not necessary.

## Reference Information
#### Python
- [Overview of pyenv, virtualenv, pipenv, poetry](https://blog.serverworks.co.jp/pyenv-virtualenv-pipenv-poetry)
- [Summary of Python development with Pipenv](https://qiita.com/y-tsutsu/items/54c10e0b2c6b565c887a)
- [Starting quickly with Poetry](https://qiita.com/ksato9700/items/b893cf1db83605898d8a)