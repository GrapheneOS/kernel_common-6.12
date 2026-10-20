#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
shopt -s nullglob

KERNEL_VERSION="6.12"

case ${ARCH:-} in
        arm64) kernel_image=Image.gz; kernel_suffix=-gz ;;
        x86_64) kernel_image=bzImage; kernel_suffix= ;;
        *) echo "ARCH is undefined or unknown" >&2; exit 1 ;;
esac

test -d "${ANDROID_BUILD_TOP:-}" || { echo "ANDROID_BUILD_TOP is undefined or missing" >&2; exit 1; }

# Select modules from the new build and avoid duplicating GKI modules.
common_modules=(common_dist/*.ko)
virt_modules=()
for module in virt_dist/*.ko; do
        if [[ ! -f common_dist/${module##*/} ]]; then
                virt_modules+=("$module")
        fi
done
test -s "common_dist/${kernel_image}"
(( ${#common_modules[@]} && ${#virt_modules[@]} ))

PREBUILT_PATH="$ANDROID_BUILD_TOP/prebuilts/qemu-kernel/${ARCH}/${KERNEL_VERSION}"
GKI_MODULES_PATH="${PREBUILT_PATH}/gki_modules"
VIRT_MODULES_PATH="${PREBUILT_PATH}/goldfish_modules"

mkdir -p "${GKI_MODULES_PATH}" "${VIRT_MODULES_PATH}"
cp "$@" -- "${common_modules[@]}" "${GKI_MODULES_PATH}/"
cp "$@" -- "${virt_modules[@]}" "${VIRT_MODULES_PATH}/"
cp "$@" -- "common_dist/${kernel_image}" "${PREBUILT_PATH}/kernel-${KERNEL_VERSION}${kernel_suffix}"
