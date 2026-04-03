#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y sudo git android-sdk-platform-tools python-is-python3 python3-yaml qemu-utils  bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev lib32z1-dev libdw-dev libelf-dev lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev meson-1.5 glslang-tools python3-mako
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
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --no-clone-bundle
repo sync -c -j 8 # $(nproc)

source build/envsetup.sh
export AB_OTA_UPDATER=true ROOMSERVICE_BRANCHES="lineage-23.1 lineage-23.0"
breakfast virtio_arm64only_go
echo "CONFIG_RTC_CLASS=y" >> kernel/virt/virtio/arch/arm64/configs/lineageos/virtio.config
echo "CONFIG_ALARMTIMER=y" >> kernel/virt/virtio/arch/arm64/configs/lineageos/virtio.config
m recoveryimage
breakfast virtio_arm64only user
m vm-utm-zip otapackage
