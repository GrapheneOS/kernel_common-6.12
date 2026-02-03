#!/usr/bin/env bash

#set -e

KERNEL_VERSION="6.12"

kernel_image_src=
kernel_image_dst=
if [[ "${ARCH}" == "arm64" ]]; then
        # https://github.com/GrapheneOS/device_generic_goldfish/blob/16-qpr2/board/kernel/arm64.mk
        kernel_image_src="Image.gz"
        kernel_image_dst="kernel-${KERNEL_VERSION}-gz"
elif [[ "${ARCH}" == "x86_64" ]]; then
	# https://github.com/GrapheneOS/device_generic_goldfish/blob/16-qpr2/board/kernel/x86_64.mk
        kernel_image_src="bzImage"
        kernel_image_dst="kernel-${KERNEL_VERSION}"
else
        echo "ARCH is undefined or unknown"
        exit 1
fi

test -d "$ANDROID_BUILD_TOP" || (echo "ANDROID_BUILD_TOP is undefined or missing" && exit 1)

PREBUILT_PATH="$ANDROID_BUILD_TOP/prebuilts/qemu-kernel/${ARCH}/${KERNEL_VERSION}"
GKI_MODULES_PATH="${PREBUILT_PATH}/gki_modules"
VIRT_MODULES_PATH="${PREBUILT_PATH}/goldfish_modules"

for file in $(find ${GKI_MODULES_PATH} -maxdepth 1 -type f -printf "%f\n"); do
        cp "$@" common_dist/$file ${GKI_MODULES_PATH}/$file > /dev/null 2>&1
done
cp "$@" common_dist/${kernel_image_src} ${PREBUILT_PATH}/${kernel_image_dst}
[[ "${ARCH}" == "x86_64" ]] && cp "$@" virt_dist/{mac80211,cfg80211}.ko ${GKI_MODULES_PATH}
for file in $(find ${VIRT_MODULES_PATH} -maxdepth 1 -type f -printf "%f\n"); do
        cp "$@" virt_dist/$file ${VIRT_MODULES_PATH}/$file
done
