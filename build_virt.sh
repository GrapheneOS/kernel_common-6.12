#!/usr/bin/env bash

set -e

CLANG_VERSION="r510928"

[[ "${ARCH}" =~ aarch64|x86_64 ]] || (echo "unknown or undefined ARCH" && exit 1)

cert_pem=$(mktemp)
cert_x509=$(mktemp)
sign_file=$(mktemp)

trap '{ rm -f -- "$sign_file" "$cert_pem" "$cert_x509"; }' EXIT

# clean out/ to avoid confusion with signing keys
test -d out/ && rm -rf out/

function find_in_out(){
	find out/bazel/output_user_root/*/execroot -type f -name $1
}

tools/bazel run --lto=full "$@" //common:kernel_${ARCH}_dist -- --dist_dir=common_dist

cp $(find_in_out "signing_key.pem") ${cert_pem}
cp $(find_in_out "signing_key.x509") ${cert_x509}

tools/bazel run --lto=full "$@" //common-modules/virtual-device:virtual_device_${ARCH}_dist -- --dist_dir=virt_dist

prebuilts/clang/host/linux-x86/clang-${CLANG_VERSION}/bin/clang common/scripts/sign-file.c -lssl -lcrypto -o ${sign_file}
find virt_dist/ -type f -name "*.ko" \
  -exec ${sign_file} sha256 ${cert_pem} ${cert_x509} {} \;

mapfile -t common_sig < <(modinfo common_dist/*.ko | grep "sig_key" | awk '{print $NF}')
mapfile -t virt_sig < <(modinfo virt_dist/*.ko | grep "sig_key" | awk '{print $NF}')
if [[ "$ARCH" == "x86_64" ]]; then [[ $common_sig == $virt_sig ]] && echo "Signature verification success" || echo "Signature verification failure"; fi
