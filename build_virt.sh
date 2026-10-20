#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

[[ ${ARCH:-} =~ ^(aarch64|x86_64)$ ]] || { echo "unknown or undefined ARCH" >&2; exit 1; }

tools/bazel run "$@" "//common:kernel_${ARCH}_dist" -- --wipe_destdir --destdir=common_dist
tools/bazel run "$@" "//common-modules/virtual-device:virtual_device_${ARCH}_dist" -- --wipe_destdir --destdir=virt_dist

# Query the outputs of this configuration rather than searching cached builds
# for signing keys. The kernel and both module sets must use the same key.
execroot=$(tools/bazel info execution_root)
cert_pem=$(tools/bazel cquery "$@" --output=files --output_groups=certs/signing_key.pem "//common:kernel_${ARCH}")
cert_x509=$(tools/bazel cquery "$@" --output=files --output_groups=certs/signing_key.x509 "//common:kernel_${ARCH}")
sign_file=$(tools/bazel cquery "$@" --output=files --output_groups=scripts/sign-file "//common:kernel_${ARCH}")

# Both distributions contain the same already-signed GKI modules.
for module in virt_dist/*.ko; do
    if [[ ! -f common_dist/${module##*/} ]]; then
        "${execroot}/${sign_file}" sha256 "${execroot}/${cert_pem}" "${execroot}/${cert_x509}" "$module"
    fi
done
