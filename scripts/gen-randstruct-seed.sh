#!/bin/sh
# SPDX-License-Identifier: GPL-2.0

SEED=$(echo -n $KBUILD_BUILD_TIMESTAMP | sha256sum | cut -f 1 -d ' ')
echo "$SEED" > "$1"
HASH=$(echo -n "$SEED" | sha256sum | cut -d" " -f1)
echo "#define RANDSTRUCT_HASHED_SEED \"$HASH\"" > "$2"
