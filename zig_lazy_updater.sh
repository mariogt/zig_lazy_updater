#!/bin/bash

#  zig_lazy_updater.sh
#  Created by Mario Gajardo Tassara --> 16-07-2022
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


zig_dev_release_to_check="zig-linux-x86_64-0.10.0-dev.*.tar.xz"

clear
echo ""
echo "🎉 Lazy Man Updater/Installer for Zig dev release 🎉"
echo ""

if ! command -v zig &> /dev/null
then
    echo "*** I can't find Zig in your Path variables!"
    echo ""
else
    zig_installed_version=$(zig version)
    zig_dev_latest_version=$(curl -s https://ziglang.org/download/ | grep -o $zig_installed_version | uniq)
fi

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
    cd ~/Downloads

    wget -q --no-parent -r --exclude-directories=/documentation,/news,/zsf,/learn,/de,/es,/fr,/it,/ar,/fa,/pt,/zh,/ko,/perf -A $zig_dev_release_to_check https://ziglang.org/

    mv ziglang.org/builds/zig* ~/ && rm -rf ziglang.org

    echo "✅ Download complete!"
    echo ""

    cd ~/

    if [ -e "zig" ];
    then
	    rm -rf zig
	    echo "-> Old zig installation was found and deleted!"
        echo ""
    fi

    zig_full_path=$(ls | grep "zig-*")
    zig_full_file_name=$(basename "$zig_full_path")
    zig_version=${zig_full_file_name%.*.*}

    tar -xf zig-*
    rm zig-*.tar.xz
    mv ~/zig-* ~/zig
    echo "⚡$zig_version installed in $HOME/zig"
    echo ""
    echo "Add $HOME/zig to your Path, write this line to your shell config file (like .bashrc)"
    echo 'export PATH="$HOME/zig:$PATH"'
fi
