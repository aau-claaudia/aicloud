#!/bin/bash
#
# Created 2024-03-18 by Jorgen Bjornstrup (jorgen@its.aau.dk)
#
# ... to replace former script created 2021-10-06 by Kristian Mide (fas@mide.dk)

## @file  quota.sh
## @brief Bash script to show and set CephFS disk quota for, e.g., homedirs
## @details
## ```text
## Usage: quota.sh [<directory> [<quota>]]
##
## Args:
## With 0 arguments, called by PAM during user login:
##   Set the default quota, e.g., 1TiB, for the homedir of the user, iff the
##   homedir is without quota, and then show the disk usage and quota.
##   The script will exit immediately if called by PAM for the root user.
## With 0 arguments: Show disk usage and quota for the homedir of current user.
## With 1 argument:  Show disk usage and quota for the specified directory.
## With 2 arguments: Set specified disk quota for the specified directory.
## <quota> must be the quota in bytes, or a number with a binary unit suffix.
## ... 1K=1024, 1M=1024K, 1G=1024M, 1T=1024G, ...

# Default quota for homedirs without exiting quota setting
quota_default="1T"

set -o errexit

function usage
{
    cat $0|grep ^##|cut -c4- |\
        sed -e 's/^@brief  *\|^@details *\|^```.*//' |\
        tail -n+2|cat -s
    exit $1
}

function quota_usage
{
    local dir="$1"
    local usage=`getfattr --absolute-names --only-values \
			  -n ceph.dir.rbytes "$dir" 2>/dev/null || echo 0`
    local usage_text=`numfmt --to=iec-i --suffix=B "$usage"`
    local quota=`getfattr --absolute-names --only-values \
                 	  -n ceph.quota.max_bytes "$dir" 2>/dev/null || echo 0`
    local quota_text=`numfmt --to=iec-i --suffix=B "$quota"`
    echo "Disk usage and quota for $dir: $usage_text / $quota_text"   
}

function quota_get
{
    local dir="$1"
    local quota=`getfattr --absolute-names --only-values \
                 	  -n ceph.quota.max_bytes "$dir" 2>/dev/null || echo 0`
    echo "$quota"
}

function quota_set
{
    local dir="$1"
    local quota="$2"
    local quota_bytes=`numfmt --from=iec "$quota"`
    echo "Setting disk quota for $dir to $quota."
    setfattr -n ceph.quota.max_bytes -v "$quota_bytes" "$dir"
}

if [ $# -eq 0 ]
then if [ -n "$PAM_TYPE" ]
     then if [ "$PAM_TYPE" = "open_session" ]
	  then if [ "$PAM_USER" = "root" ]
	       then exit 0
	       fi
	       homedir=$(getent passwd "$PAM_USER" | cut -d: -f6)
	       if [ `quota_get "$homedir"` -eq 0 ]
	       then quota_set "$homedir" "$quota_default"
	       fi
	       quota_usage "$homedir"
	       exit 0
	  else
	      exit 0
	  fi
     else homedir=$(getent passwd "$USER" | cut -d: -f6)
	  quota_usage "$homedir"
	  exit 0
     fi
elif [ $# -eq 1 -a -d "$1" ]
then dir="$1"
     quota_usage "$dir"
     exit 0
elif [ $# -eq 2 -a -d "$1" ]
then dir="$1"
     quota="$2"
     quota_set "$dir" "$quota"
     quota_usage "$dir"
     exit 0
fi
if [ $# -ge 1 -a ! -d "$1" ]
then echo "Error: Not a directory: $1"
     echo
fi
usage 1


