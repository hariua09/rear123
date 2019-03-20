# This file is part of Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.
#
# 500_make_backup.sh

include_list=()

# Check if backup-include.txt (created by 400_create_include_exclude_files.sh),
# really exists.
if [ ! -r $TMP_DIR/backup-include.txt ]; then
    Error "Can't find include list"
fi

# Create Borg friendly include list.
for i in $(cat $TMP_DIR/backup-include.txt); do
    include_list+=("$i ")
done

# User might specify some additional output options in Borg.
# Output shown by Borg is not controlled by `rear --verbose' nor `rear --debug'
local borg_additional_options=''

is_true $BORGBACKUP_SHOW_PROGRESS && borg_additional_options+='--progress '
is_true $BORGBACKUP_SHOW_STATS && borg_additional_options+='--stats '

# Start actual Borg backup.
Log "Creating archive ${BORGBACKUP_ARCHIVE_PREFIX}_$BORGBACKUP_SUFFIX \
in repository $BORGBACKUP_REPO"

borg create --one-file-system $borg_additional_options $verbose \
$BORGBACKUP_OPT_COMPRESSION $BORGBACKUP_OPT_REMOTE_PATH \
$BORGBACKUP_OPT_UMASK --exclude-from $TMP_DIR/backup-exclude.txt \
${borg_dst_dev}${BORGBACKUP_REPO}::\
${BORGBACKUP_ARCHIVE_PREFIX}_$BORGBACKUP_SUFFIX \
${include_list[@]} 0<&6 1>&7 2>&8

StopIfError "Failed to create backup"
