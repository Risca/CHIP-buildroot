#!/bin/sh

set -e
set -x

device_type=$(cat ${TARGET_DIR}/etc/mender/device_type | sed 's/[^=]*=//')
artifact_name=$(cat ${TARGET_DIR}/etc/mender/artifact_info | sed 's/[^=]*=//')

if [ -z "${device_type}" ] || [ -z "${artifact_name}" ]; then
	echo "missing files required by Mender"
	exit 1
fi

${HOST_DIR}/bin/mender-artifact write rootfs-image \
	--file ${BINARIES_DIR}/rootfs.ubifs \
	--output-path ${BINARIES_DIR}/${artifact_name}.mender \
	--artifact-name ${artifact_name} \
	--device-type ${device_type}
