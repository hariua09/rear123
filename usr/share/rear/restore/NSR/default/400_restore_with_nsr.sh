# 400_restore_with_nsr.sh
#
# In case NSR_CLIENT_MODE is enabled we need to prompt and wait
# until the restore rpocess executed at the NSRSERVER has finished.
#

if is_true "$NSR_CLIENT_MODE"; then
    LogPrint "Please let the restore process start on Your backup server i.e. $(cat $VAR_DIR/recovery/nsr_server)."
    LogPrint "Make sure all required data is restored to $TARGET_FS_ROOT ."
    LogPrint ""
    LogPrint "When the restore is finished type 'exit' to continue the recovery."
    LogPrint "Info: You can check the recovery process i.e. with the command 'df'."
    LogPrint ""

    rear_shell "Has the restore been completed and are You ready to continue the recovery?"
else
    LogUserOutput "Starting nsrwatch on console 8"
    TERM=linux nsrwatch -p 1 -s $(cat $VAR_DIR/recovery/nsr_server ) </dev/tty8 >/dev/tty8 &

    LogUserOutput "Restore filesystem $(cat $VAR_DIR/recovery/nsr_paths) with recover"

    blank=" "
    # Use the original STDOUT when 'rear' was launched by the user for the 'while read ... echo' output
    # (which also reads STDERR of the 'recover' command so that 'recover' errors are 'echo'ed to the user)
    # but keep STDERR of the 'while' command going to the log file so that 'rear -D' output goes to the log file:
    recover -s $(cat $VAR_DIR/recovery/nsr_server) -c $(hostname) -d $TARGET_FS_ROOT -a $(cat $VAR_DIR/recovery/nsr_paths) 2>&1 \
      | while read -r ; do
            echo -ne "\r${blank:1-COLUMNS}\r"
            case "$REPLY" in
                *:*\ *)
                    echo "$REPLY"
                    ;;
                ./*)
                    if [ "${#REPLY}" -ge $((COLUMNS-5)) ] ; then
                        echo -n "... ${REPLY:5-COLUMNS}"
                    else
                        echo -n "$REPLY"
                    fi
                    ;;
                *)
                    echo "$REPLY"
                    ;;
            esac
        done 1>&7
fi
