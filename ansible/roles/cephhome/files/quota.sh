#!/bin/bash -e

[ "$PAM_TYPE" = "open_session" ] || exit 0

# 1024 Gb for everyone
SIZE=$(bc <<< "1024^3*1024")
DIRECTORY=$(getent passwd ${PAM_USER} | cut -d: -f6)

logger "Setting ${SIZE} byte quota for ${PAM_USER} on ${DIRECTORY}"
setfattr -n ceph.quota.max_bytes -v ${SIZE} ${DIRECTORY}

# numfmt --to=iec-i --suffix=B `getfattr --absolute-names --only-values -n ceph.quota.max_bytes ${DIRECTORY}`

USAGE=$(numfmt --to=iec-i --suffix=B `getfattr --absolute-names --only-values -n ceph.dir.rbytes ${DIRECTORY}`)
AVAILABLE=$(numfmt --to=iec-i --suffix=B ${SIZE})
echo "Current quota usage: ${USAGE} / ${AVAILABLE}"