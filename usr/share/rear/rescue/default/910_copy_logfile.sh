# Copy current unfinished logfile to initramfs for debug purpose.

if is_true "$EXCLUDE_RUNTIME_LOGFILE"; then
    Log "Excluding logfile from initramfs (EXCLUDE_RUNTIME_LOGFILE=\"$EXCLUDE_RUNTIME_LOGFILE\")"
    return 0
fi

# Usually RUNTIME_LOGFILE=/var/log/rear/rear-$HOSTNAME.log
# The RUNTIME_LOGFILE name is set by the main script from LOGFILE in default.conf
# but later user config files are sourced in the main script where LOGFILE can be set different
# so that the user config LOGFILE basename (except a trailing '.log') is used as target logfile name:
logfile_basename=$( basename $LOGFILE )
LogPrint "Copying logfile $RUNTIME_LOGFILE into initramfs as '/tmp/${logfile_basename%.*}-partial-$(date -Iseconds).log'"
mkdir -p $v $ROOTFS_DIR/tmp >&2
cp -a $v $RUNTIME_LOGFILE $ROOTFS_DIR/tmp/${logfile_basename%.*}-partial-$(date -Iseconds).log >&2
