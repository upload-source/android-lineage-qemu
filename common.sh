#!/bin/bash

version_at_commit() {
  git -C "$TMP" ls-tree -r --name-only "$1" \
    | grep 'RELEASE_PLATFORM_SECURITY_PATCH\.textproto' \
    | while read -r p; do git -C "$TMP" show "$1:$p"; done \
    | grep -oP 'string_value:\s*"\K[0-9-]+' | sort -u | tail -1
}

check_version() {
  TMP=$(mktemp -d)
  trap 'rm -rf "$TMP"' EXIT
  GIT_LFS_SKIP_SMUDGE=1 git clone --quiet --filter=blob:none --no-checkout https://github.com/LineageOS/android_vendor_lineage "$TMP"
  BUILD_TAG=$(git tag -l 'v*' --sort=-v:refname 2>/dev/null | head -1 || true)
  BUILD_DATE=${BUILD_TAG#v}; BUILD_DATE=${BUILD_DATE//./-}
  BUILD_COMMIT=$(git -C "$TMP" rev-list -1 --before="$BUILD_DATE" HEAD)

  [ "$(version_at_commit HEAD || true)" = "$(version_at_commit "$BUILD_COMMIT" || true)" ]
}
