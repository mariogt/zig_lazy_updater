#!/bin/bash

#  zig_lazy_updater.sh
#  By Mario Gajardo Tassara --> 16-07-2022
#
#  Zig Lazy Man Installer/Updater
#
#  Script to update/install the latest dev build of Zig into your $HOME folder
#  Beware that this script delete the old zig folder present in your $HOME
#  Feel free to mod this script to your needs
#
#  Copyright (c) MarioGT Software 2022.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this text and associated documentation files (the "Text"), to deal
#  in the Text without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Text, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Text.

#  THE TEXT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE TEXT OR THE USE OR OTHER DEALINGS dtt TEXT.


# zig dev release to check
# here you can mod it to check for windows or mac versions
zig_dev_release_to_check="zig-linux-x86_64-0.10.0-dev.*.tar.xz"

clear
echo ""
echo "🎉 Lazy Man Updater/Installer for Zig dev release 🎉"
echo ""

# deleting the zig_temp_download folder if exist
if [ -d $HOME/zig_temp_download ]
then
    rm -rf $HOME/zig_temp_download
fi

cd $HOME

# checking if zig is installed and present in your $PATH
if ! command -v zig &> /dev/null
then
	echo "*** I can't find Zig installed"
	echo ""
else
    # if zig is installed then we store the local version
	zig_installed_version=$(zig version)

    # searching for the local version number on the zig website,
    # if is founded then zig_dev_latest_version var is not nil
    zig_dev_latest_version=$(curl -s https://ziglang.org/download/ | grep -o $zig_installed_version | uniq)
fi

# checking if is needed to install/update zig
# if zig_dev_latest_version != nil --> zig installed locally is already at its latest version
# if zig_dev_latest_version == nil --> zig isn't installed locally or is obsolete

if [ -n "$zig_dev_latest_version" ];
then
	echo "🐸 Doing nothing 🐸"
	echo ""
	echo "*** You have already the latest dev release!"
	echo "⚡Zig $zig_dev_latest_version"
else
	echo "*** New version of Zig dev release found!"
	echo ""
	echo "🌎 Downloading the latest dev build ..."

    # checking if we can use the Downloads folder for temporarily store the downloaded files
	if [ -e $HOME/.config/user-dirs.dirs ]
	then
        # storing the user default Download folder name, in whatever language, with the help of grep and awk
		downloadFolder=$HOME/$(cat $HOME/.config/user-dirs.dirs | grep "XDG_DOWNLOAD_DIR" | grep -oP '(?<=/)[^ ]*' | awk '{ print substr( $0, 1, length($0)-1) }')

        # if the Download folder doesn't exist for whatever reason (like on Windows WSL distros)
        # create a temp directory for store the downloaded data
	else
        if [ -d "$/HOME/zig_temp_download" ]
        then
		    downloadFolder="$HOME/zig_temp_download"
        else
		    mkdir zig_temp_download
            downloadFolder="$HOME/zig_temp_download"
        fi
	fi
	cd $downloadFolder

    # get the latest zig dev compilation with wget
	wget -q --no-parent -r --exclude-directories=/documentation,/news,/zsf,/learn,/de,/es,/fr,/it,/ar,/fa,/pt,/zh,/ko,/perf -A $zig_dev_release_to_check https://ziglang.org/

    # moving the zig compressed file to your $HOME, then we delete the temp dir $HOME/$downloadFolder
	mv ziglang.org/builds/zig* $HOME && rm -rf ziglang.org

    # deleting the zig_temp_download folder if exist
    if [ -d $HOME/zig_temp_download ]
    then
        rm -rf $HOME/zig_temp_download
    fi

	echo "✅ Download complete!"
	echo ""

	cd $HOME

    # check if an old zig installation is present
    # if exist we zap it!
	if [ -e "zig" ];
	then
		rm -rf zig
		echo "-> Old zig installation was found and deleted!"
		echo ""
	fi

    # storing the zig version number from the downloaded file
	zig_full_path=$(ls | grep "zig-*")
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
	echo "Add $HOME/zig to your Path, write this line to your shell config file (like .bashrc)"
	echo 'export PATH="$HOME/zig:$PATH"'
fi
