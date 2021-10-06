#!/bin/bash -e

[ "$PAM_TYPE" = "open_session" ] || exit 0

# 128 Gb for everyone
SIZE=$(bc <<< "1024^3*128")
DIRECTORY=$(getent passwd ${PAM_USER} | cut -d: -f6)

logger "Setting ${SIZE} byte quota for ${PAM_USER} on ${DIRECTORY}"
setfattr -n ceph.quota.max_bytes -v ${SIZE} ${DIRECTORY}
