#!/bin/bash

#  zig_lazy_updater.sh
#  By Mario Gajardo Tassara --> 16-07-2022
#
#  Zig Lazy Man Installer/Updater
#
#  Update or install the latest dev build of Zig into your $HOME folder
#  This script works on MacOS, Linux and WSL
#
#  THE TEXT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE TEXT OR THE USE OR OTHER DEALINGS dtt TEXT.

# version number substring, to insert into zig_dev_release_to_check
# Detect the operating system
OS=$(uname -s)
case $OS in
Darwin*)
  zig_dev_ver_string="0.15.0"
  ;;
Linux*)
  # scaped with \ for regex work
  zig_dev_ver_string="0.15.0"
  ;;
*)
  echo "*** Unsupported OS ***"
  exit 1
  ;;
esac

# updater function
worker() {
  # zig dev release to check
  zig_dev_release_to_check="$1"

  # deleting the zig_temp_download folder if exist
  if [ -d "$HOME"/zig_temp_download ]; then
    rm -rf "$HOME"/zig_temp_download
  fi

  cd "$HOME" || exit

  # checking if zig is installed and present in your $PATH
  if ! command -v zig &>/dev/null; then
    echo "*** I can't find Zig installed"
    echo ""
  else
    # if zig is installed store the local version
    zig_installed_version=$(zig version)

    # search if the local zig version number is present on the zig website,
    zig_dev_latest_version=$(curl -s https://ziglang.org/download/ | grep -o "$zig_installed_version" | uniq)
  fi

  # if zig_dev_latest_version != nil --> zig installed locally is already at its latest version
  # if zig_dev_latest_version == nil --> zig isn't installed locally or it obsolete

  if [ -n "$zig_dev_latest_version" ]; then
    echo "🐸 Doing nothing 🐸"
    echo ""
    echo "*** You have already the latest dev release!"
    echo "⚡Zig $zig_dev_latest_version"
  else
    echo "*** New version of Zig dev release found!"
    echo ""
    echo "🌎 Downloading the latest dev build ..."

    # checking for user default Downloads folder for storing the downloaded files
    if [ -e "$HOME"/.config/user-dirs.dirs ]; then
      # storing the user default Download folder name, in whatever language, with the help of grep and awk
      downloadFolder="$HOME"/$(cat "$HOME/.config/user-dirs.dirs" | grep "XDG_DOWNLOAD_DIR" | grep -oP '(?<=/)[^ ]*' | awk '{ print substr( $0, 1, length($0)-1) }')

      # if user-dirs doesn't exist like on macOS or WSL then
      # create a temp directory for storing the downloaded data
    else
      mkdir "$HOME/zig_temp_download"
      downloadFolder="$HOME/zig_temp_download"
    fi
    cd "$downloadFolder" || exit

    # get the latest zig dev compilation with wget and regex
    case $OS in
    Darwin*)
      wget -q --no-check-certificate --no-parent -r --exclude-directories=/css,/devlog,/documentation,/download,/news,/sponsors,/zsf,/learn -A "$zig_dev_release_to_check" https://ziglang.org
      ;;
    Linux*)
      wget -q --no-check-certificate --no-parent -r --exclude-directories=/css,/devlog,/documentation,/download,/news,/sponsors,/zsf,/learn -A "$zig_dev_release_to_check" https://ziglang.org
      ;;
    *)
      echo "*** Unknown OS"
      exit 1
      ;;
    esac

    # moving the zig compressed file to your $HOME, then we delete the temp dir $HOME/$downloadFolder
    mv ziglang.org/builds/zig* "$HOME" && rm -rf ziglang.org

    # deleting the zig_temp_download folder if exist
    if [ -d "$HOME/zig_temp_download" ]; then
      rm -rf "$HOME/zig_temp_download"
    fi

    echo "✅ Download complete!"
    echo ""

    cd "$HOME" || exit

    # check if an old zig installation is present
    # if exist we zap it!
    if [ -e "zig" ]; then
      rm -rf zig
      echo "-> Old zig installation was found and deleted!"
      echo ""
    fi

    # storing the zig version number from the downloaded file
    zig_full_path=$(ls | grep zig-*)
    zig_full_file_name=$(basename "$zig_full_path")
    zig_version=${zig_full_file_name%.*.*}

    # extracting the zig dev compilation
    tar -xf zig-*
    # deleting the compressed file
    rm zig-*.tar.xz
    # renaming the resulting folder to "zig"
    mv $HOME/zig-* $HOME/zig

    echo "⚡$zig_version installed in $HOME/zig"
    echo ""
    echo "Add \$HOME/zig to your Path, write this line to your shell config file (like .bashrc)"
    echo "export PATH=\$HOME/zig:\$PATH"
  fi
}

# main menu function
mainMenu() {
  clear
  echo ""
  echo "🎉 Lazy Man Updater/Installer for Zig dev release 🎉"
  echo ""

  bool=true
  while [ $bool ]; do
    echo "For what platform you want to install the latest Zig dev release?"
    echo ""
    echo "1 = 🐧 Linux/WSL (x86_64)"
    echo "2 = 🍎 macOS (aarch64)"
    echo "3 = exit"
    echo ""

    echo "Type your option and press Enter: "
    read -r option
    clear

    if [ "$option" == "1" ]; then
      bool=false
      echo "🐧 Linux/WSL (x86_64) selected!"
      echo ""
      zig_dev_release_to_check="zig-x86_64-linux-$zig_dev_ver_string-dev.*.tar.xz"
      worker "$zig_dev_release_to_check"
      exit
    elif [ "$option" == "2" ]; then
      bool=false
      echo "🍎 macOS (aarch64) selected!"
      echo ""
      zig_dev_release_to_check="zig-aarch64-macos-$zig_dev_ver_string-dev.*.tar.xz"
      worker "$zig_dev_release_to_check"
      exit
    elif [ "$option" == "3" ]; then
      bool=false
      clear
      exit
    elif [ "$option" == "" ]; then
      bool=true
      echo "🔥Empty option! please try again🔥 "
      echo ""
    else
      bool=true
      echo "🔥Nonvalid option! please try again🔥"
      echo ""
    fi
  done
}

# call the main user menu function
mainMenu
