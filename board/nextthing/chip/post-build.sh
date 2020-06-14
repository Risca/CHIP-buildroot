#!/bin/bash

TARGET_DIR=$1

BRANCH=$(git symbolic-ref -q HEAD)
BRANCH=${BRANCH##refs/heads/chip/}
BRANCH=${BRANCH##refs/heads/nextthing/*/}

BUILDROOT_GITHASH="$(cat buildroot_githash)"
BUILDROOT_GITHASH="${BUILDROOT_GITHASH:0:8}"

BUILD="$(cat build)"

cat <<EOF >${TARGET_DIR}/etc/issue
Welcome to CHIP Buildroot-${BRANCH} build ${BUILD} rev ${BUILDROOT_GITHASH}

CHIP Buildroot contains various open source software.

The source code can be downloaded from:
http://opensource.nextthing.co/chip/buildroot/${BRANCH}/${BUILD}/build${BUILD}.tar.gz

EOF

if grep -Fq "ubi0:data" ${TARGET_DIR}/etc/fstab
then
    echo "fstab already has ubi0:data entry"
else
    cat >> ${TARGET_DIR}/etc/fstab << EOF
ubi0:data       /data           ubifs   defaults        0       0
EOF

fi
