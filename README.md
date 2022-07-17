# zig_lazy_updater

Script to update/install Zig's latest Linux dev build into your $HOME folder.

If you don't have a zig installation in your $HOME, then this script will install
the latest Zig dev release (from https://ziglang.org/download/) in a folder called
"zig" in your $HOME directory.

If you have already installed Zig in the $HOME/zig folder (and added it to your
$PATH), then this script will check the versions of the local installation vs the
latest official dev release, and will update the local installation if needed.

Beware that this script will delete the old zig folder present in your $HOME

Feel free to fork and mod this script to fit your needs.

![zig_lazy_updater installing](https://github.com/mariogt/zig_lazy_updater/blob/main/screenshots/installing_zig.png)
![zig_lazy_updater updating](https://github.com/mariogt/zig_lazy_updater/blob/main/screenshots/updating_zig.png)
