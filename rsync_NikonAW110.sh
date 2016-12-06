#!/bin/bash
IFS=$','

# Current Directory
CWD=$(pwd)

# Script Directory
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [ $# -lt 1 ]; then
	YEAR=`/bin/date -j +%Y`
	MONTH=`/bin/date -j +%m`
else
	YEAR=$1
	MONTH=$2
fi

# Target
TARGET_DIR="${SCRIPT_DIR}/${YEAR}-${MONTH}"

if [ ! -d "${TARGET_DIR}" ]; then
	echo "eval /bin/mkdir -pv \"${TARGET_DIR}\""
	eval /bin/mkdir -pv $TARGET_DIR
else
	echo "\"${TARGET_DIR}\" already exists!"
fi

# cd $SOURCE_DIR
# cd $TARGET_DIR

TODAY=`/bin/date -j +%Y%m%d_%H%M%S`

START_DATE="${YEAR}-${MONTH}-01"
END_DATE=`/bin/date -j -v +1m -f %Y-%m-%d ${START_DATE} +%Y-%m-%d`
# echo /bin/date -j -v +1d -f %Y-%m-%d ${START_DATE} +%Y-%m-%d

RSYNC_INCLUDE="${SCRIPT_DIR}/rsync_include_${YEAR}-${MONTH}_${TODAY}.txt"
echo "\$RSYNC_INCLUDE = ${RSYNC_INCLUDE}"
touch "${RSYNC_INCLUDE}"
echo "- ._*" 1> "${RSYNC_INCLUDE}"

# echo /usr/bin/find "\"${CWD}\"" -type f -newermt "\"${START_DATE}\"" -not -newermt "\"${END_DATE}\"" -print \| sed 's:.*/::' 1\> "\"${RSYNC_INCLUDE}\""
# /usr/bin/find "\"${CWD}\"" -type f -newermt "\"${START_DATE}\"" -not -newermt "\"${END_DATE}\"" -print | sed 's:.*/::' 1> "\"${RSYNC_INCLUDE}\""

echo "/usr/bin/find ${CWD} -type f -newermt $START_DATE -not -newermt $END_DATE -print | sed 's:.*/:+ :' 1\> ${RSYNC_INCLUDE}"
/usr/bin/find ${CWD} -type f -newermt $START_DATE -not -newermt $END_DATE -print | sed 's:.*/:+ :' 1>> "${RSYNC_INCLUDE}"

# Exclude other files
echo "- *" 1>> "${RSYNC_INCLUDE}"

# rsync SOURCE (CWD) to TARGET
echo /usr/bin/rsync -rt --progress --remove-source-files --include-from="${RSYNC_INCLUDE}" "$CWD/" "$TARGET_DIR/"
/usr/bin/rsync -rt --progress --remove-source-files --include-from="${RSYNC_INCLUDE}" "$CWD/" "$TARGET_DIR/"
unset IFS
exit 0

## http://stackoverflow.com/questions/16765406/rsync-transfer-only-files-whose-file-name-starts-with-todays-date
## find /Volumes/Kingston/DCIM/100CANON -type f -iname "*.mov" -newermt 2014-11-22 -not -newermt 2014-11-23 -print0 | rsync -tvz --files-from=- --from0 '/Volumes/Kingston/DCIM/100CANON' '/Volumes/Public/Shared Pictures/test_rsync'

# Diff SOURCE and TARGET file and remove files from SOURCE if no difference
grep -e '^\+ ' ${RSYNC_INCLUDE} | grep -v -e '^\+ ._' | cut -c 3- | while read LINE
do
#	diff $CWD/$LINE $TARGET_DIR/$LINE > /dev/null 2>&1 && /bin/echo -n "Same, Same - Deleting $CWD/$LINE" && rm $CWD/$LINE || /bin/echo -n " - $? Files Different"; /bin/echo ;
	diff $CWD/$LINE $TARGET_DIR/$LINE
	case "$?" in
	0)	echo "diff $CWD/$LINE $TARGET_DIR/$LINE - Same, Same - Deleting.."
		rm ${CWD}/$LINE
		;;
	1)	echo "diff $CWD/$LINE $TARGET_DIR/$LINE - Files Different."
		;;
	*)	echo "diff $CWD/$LINE $TARGET_DIR/$LINE - Error code [$DIFF] not handled."
		;;
	esac
done
unset IFS
exit 0

#if [ $# -ne 1 ];then
#	when="today"
#else
#	when=` date -d "$1" +"%s" `
#fi
#now=`date +"%s"`
#
#seconds=`echo "$when - $now" | bc`
#minutes=`echo "$seconds / 60 " | bc `

#find . -cmin $minutes -print
