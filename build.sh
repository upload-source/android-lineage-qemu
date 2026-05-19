#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export _JAVA_OPTIONS="-Xmx25g"
export LZ4_COMPRESSION_LEVEL=9
export ANDROID_QUIET_BUILD=true
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export PYTHONDONTWRITEBYTECODE=true
export BUILD_ENFORCE_SELINUX=1
export DEBIAN_FRONTEND=noninteractive
ccache -M 50G
cd lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --no-clone-bundle --depth=1
repo sync -j 4 --fail-fast --force-sync --no-clone-bundle
source build/envsetup.sh
breakfast virtio_arm64only user 
m vm-utm-zip
ZIP_PATH=$(find lineage/out/target/product/virtio_arm64only/ -name "UTM-VM*.zip" | head -n 1)
if [ -f "$ZIP_PATH" ]; then
    RELEASE_TAG="build-$(date +'%Y%m%d-%H%M')"  
    gh release create "$RELEASE_TAG" "$ZIP_PATH" \
        --repo "upload-source/android-lineage-qemu" \
        --title "LineageOS VirtIO ARM64 ($RELEASE_TAG)" \
        --notes "Compilation automatique réussie sur l'agent TeamCity Cloud (c5d.2xlarge)."
    echo "success !"
else
    echo "Error 404."
    exit 1
fi
