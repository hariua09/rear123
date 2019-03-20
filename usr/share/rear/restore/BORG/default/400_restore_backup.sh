# This file is part of Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.
#
# 400_restore_backup.sk

# Borg restores to cwd.
# Switch current working directory or die.
pushd $TARGET_FS_ROOT >/dev/null
StopIfError "Could not change directory to $TARGET_FS_ROOT"

# Start actual restore.
# Scope of LC_ALL is only within run of `borg extract'.
# This avoids Borg problems with restoring UTF-8 encoded files names in archive
# and should not interfere with remaining stages of rear recover.
# This is still not the ideal solution, but best I can think of so far :-/.
LogPrint "Recovering from Borg archive $BORGBACKUP_ARCHIVE"

# User might specify some additional output options in Borg.
# Output shown by Borg is not controlled by `rear --verbose' nor `rear --debug'
local borg_additional_options=''

is_true $BORGBACKUP_SHOW_PROGRESS && borg_additional_options+='--progress '

LC_ALL=rear.UTF-8 \
borg extract --sparse $borg_additional_options $BORGBACKUP_OPT_REMOTE_PATH \
${borg_dst_dev}${BORGBACKUP_REPO}::$BORGBACKUP_ARCHIVE 0<&6 1>&7 2>&8

LogPrintIfError "Error was reported during Borg restore"
LogPrint "Borg OS restore finished successfully"
popd >/dev/null
