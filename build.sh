#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export _JAVA_OPTIONS="-Xmx8g"
export LZ4_COMPRESSION_LEVEL=9
export ANDROID_QUIET_BUILD=true
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
ccache -M 20G
export CCACHE_EXEC=/usr/bin/ccache
export PYTHONDONTWRITEBYTECODE=true
export BUILD_ENFORCE_SELINUX=1
ccache -M 50G
sudo apt update
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev lib32z1-dev libdw-dev libelf-dev libgnutls28-dev lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc xxd zip zlib1g-dev meson glslang-tools python3-mako python-is-python3
wget https://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2_amd64.deb && sudo dpkg -i libtinfo5_6.3-2_amd64.deb && rm -f libtinfo5_6.3-2_amd64.deb
wget https://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.3-2_amd64.deb && sudo dpkg -i libncurses5_6.3-2_amd64.deb && rm -f libncurses5_6.3-2_amd64.deb
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global trailer.changeid.key "Change-Id"
git config --global color.ui true
git lfs install
unset REPO_URL
mkdir -p bin android/lineage
curl https://storage.googleapis.com/git-repo-downloads/repo > bin/repo
chmod a+x bin/repo
export PATH="$(realpath .)/bin:$PATH"
cd android/lineage
export PATH="$(realpath .)/prebuilts/sdk/tools/linux/bin/:$PATH"
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --no-clone-bundle --depth=1 -g default,arm64,-arm,-riscv,-riscv64,-x86,-x86_64,-mips,-darwin
repo sync -c -j8 --no-tags --no-clone-bundle --optimized-fetch --prune

source build/envsetup.sh
export AB_OTA_UPDATER=true ROOMSERVICE_BRANCHES="lineage-23.1 lineage-23.0"
echo "CONFIG_RTC_CLASS=y" >> kernel/virt/virtio/arch/arm64/configs/lineageos/virtio.config
echo "CONFIG_ALARMTIMER=y" >> kernel/virt/virtio/arch/arm64/configs/lineageos/virtio.config
breakfast virtio_arm64only user 
m vm-utm-zip
