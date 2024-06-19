#!/usr/bin/env bash

#set -e

KERNEL_VERSION="6.12"

kernel_image_src=
kernel_image_dst=
if [[ "${ARCH}" == "arm64" ]]; then
        # https://github.com/GrapheneOS/device_generic_goldfish/blob/14/board/kernel/arm64.mk#L52
        kernel_image_src="Image.gz"
        kernel_image_dst="kernel-${KERNEL_VERSION}-gz"
elif [[ "${ARCH}" == "x86_64" ]]; then
        kernel_image_src="bzImage"
        kernel_image_dst="kernel-${KERNEL_VERSION}"
else
        echo "ARCH is undefined or unknown"
        exit 1
fi

test -d "$ANDROID_BUILD_TOP" || (echo "ANDROID_BUILD_TOP is undefined or missing" && exit 1)

COMMON_PREBUILT_PATH="$ANDROID_BUILD_TOP/kernel/prebuilts/${KERNEL_VERSION}/${ARCH}"
VIRT_PREBUILT_PATH="$ANDROID_BUILD_TOP/kernel/prebuilts/common-modules/virtual-device/${KERNEL_VERSION}/${ARCH/_/-}"

for file in $(find ${COMMON_PREBUILT_PATH} -maxdepth 1 -type f -printf "%f\n"); do
        cp "$@" common_dist/$file ${COMMON_PREBUILT_PATH}/$file > /dev/null 2>&1
done
cp "$@" common_dist/${kernel_image_src} ${COMMON_PREBUILT_PATH}/${kernel_image_dst}
test -d lib && rm -r lib
bsdtar xvf common_dist/system_dlkm_staging_archive.tar.gz >/dev/null 2>&1
rm -r ${COMMON_PREBUILT_PATH}/system_dlkm_staging/lib
cp -a "$@" lib ${COMMON_PREBUILT_PATH}/system_dlkm_staging
cp "$@" virt_dist/{mac80211,cfg80211}.ko ${COMMON_PREBUILT_PATH}
for file in $(find ${VIRT_PREBUILT_PATH} -maxdepth 1 -type f -printf "%f\n"); do
        cp "$@" virt_dist/$file ${VIRT_PREBUILT_PATH}/$file
done
