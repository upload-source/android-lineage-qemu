#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export _JAVA_OPTIONS="-Xmx20g"
export LZ4_COMPRESSION_LEVEL=9
export ANDROID_QUIET_BUILD=true
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export PYTHONDONTWRITEBYTECODE=true
export BUILD_ENFORCE_SELINUX=1
ENV DEBIAN_FRONTEND=noninteractive

# 1. Installation des paquets (Regroupés pour réduire le nombre de couches)
apt-get update && apt-get install -y \
    bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs \
    gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev \
    lib32z1-dev libdw-dev libelf-dev libgnutls28-dev lz4 libsdl1.2-dev libssl-dev \
    libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc \
    xxd zip zlib1g-dev meson glslang-tools python3-mako python-is-python3 wget \
    && rm -rf /var/lib/apt/lists/*
wget https://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2_amd64.deb && dpkg -i libtinfo5_6.3-2_amd64.deb && 
wget https://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.3-2_amd64.deb && dpkg -i libncurses5_6.3-2_amd64.deb && 
    rm -f *.deb
# 2. Installation de Repo
curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo 
chmod a+x /usr/bin/repo

# 3. Configuration de l'environnement (Persistant)
export PATH="/android/prebuilts/sdk/tools/linux/bin:${PATH}"
export CCACHE_DIR=/android/.ccache

# 4. Configuration Git
 git config --global user.name "github-actions[bot]" 
git config --global user.email "github-actions[bot]@users.noreply.github.com" 
git config --global trailer.changeid.key "Change-Id"
git config --global color.ui true 
git lfs install
ccache -M 50G
unset REPO_URL
cp lineage /android
cd /android/lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --no-clone-bundle --depth=1
repo sync -j 4 --fail-fast --force-sync --no-clone-bundle
mkdir -p kernel/virt/virtio
pwd
ls -a
source build/envsetup.sh
echo "CONFIG_RTC_CLASS=y" >> kernel/virt/virtio/arch/arm64/configs/lineageos/virtio.config
echo "CONFIG_ALARMTIMER=y" >> kernel/virt/virtio/arch/arm64/configs/lineageos/virtio.config
breakfast virtio_arm64only user 
m vm-utm-zip otapackage
