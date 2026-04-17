#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

echo "::group:: Enable RPM Fusion"

dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf5 update -y

echo "::endgroup::"

echo "::group:: Install packages"

# this installs a package from fedora repos
dnf5 install -y             \
    tmux                    \
    util-linux              \
    chezmoi                 \
    neovim                  \
    btop

echo "::endgroup::"

# Codes https://rpmfusion.org/Howto/Multimedia
echo "::group:: Install codecs"

dnf5 group install -y core
dnf5 group upgrade -y core
dnf5 group install -y multimedia
dnf5 group install -y sound-and-video

dnf5 swap -y ffmpeg-free ffmpeg --allowerasing

dnf5 update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

dnf5 install -y --skip-unavailable    \
    libvpx                            \
    mesa-va-drivers-freeworld         \
    mesa-va-drivers-freeworld.i686    \
    mesa-vulkan-drivers-freeworld     \
    ffmpeg-libs                       \
    libva                             \
    libva-utils                       \
    libavcodec-freeworld              \
    openh264                          \ 
    mozilla-openh264
    
echo "::endgroup::"

# Fonts
echo "::group:: Install codecs"

dnf5 install -y --skip-unavailable    \
    liberation-fonts                  \
    google-droid-sans-fonts
    
echo "::endgroup::"

echo "::group:: Install Hyprland and utils"

# Install hyprland from COPR
dnf5 copr enable -y "nett00n/hyprland" \

dnf5 install -y --skip-broken   \
    hyprland                    \
    xdg-desktop-portal-hyprland \
    hyprpaper                   \
    hyprpicker                  \
    hypridle                    \
    hyprlock                    \
    hyprshot                    \
    hyprpolkitagent             \
    hyprland-qt-support         \
    hyprsysteminfo              \
    hyprland-guiutils

dnf5 copr disable -y "nett00n/hyprland"

# Install additional utilities that work well with hyrpland
dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

dnf5 install -y             \
    noctalia-shell          \
    kitty                   \
    pavucontrol             \
    udiskie                 \
    brightnessctl           \
    wl-gammactl

rm /etc/yum.repos.d/terra.repo

# Install nwg-look from COPR
dnf5 copr enable -y "tofik/nwg-shell" \

dnf5 install -y \
    nwg-look

dnf5 copr disable -y "tofik/nwg-shell"

echo "Hyprland installed and utils successfully"
echo "::endgroup::"

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

# Cleanup

# Disable RPM Fusion
dnf5 remove -y rpmfusion-free-release rpmfusion-nonfree-release

#### Example for enabling a System Unit File

systemctl enable podman.socket
