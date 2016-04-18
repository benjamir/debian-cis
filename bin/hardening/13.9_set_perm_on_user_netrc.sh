#!/bin/bash

#
# CIS Debian 7 Hardening
#

#
# 13.9 Check Permissions on User .netrc Files (Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

PERMISSIONS="600"
ERRORS=0

# This function will be called if the script status is on enabled / audit mode
audit () {
    for DIR in $(cat /etc/passwd | egrep -v '(root|halt|sync|shutdown)' | awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/bin/false" && $7 !="/nonexistent" ) { print $6 }'); do
    debug "Working on $DIR"
        for FILE in $DIR/.netrc; do
            if [ ! -h "$FILE" -a -f "$FILE" ]; then
                has_file_correct_permissions $FILE $PERMISSIONS
                if [ $FNRET = 0 ]; then
                    ok "$FILE has correct permissions"
                else
                    crit "$FILE has not $PERMISSIONS permissions set"
                    ERRORS=$((ERRORS+1))
                fi
            fi
        done
    done

    if [ $ERRORS = 0 ]; then
        ok "permission $PERMISSIONS set on .netrc users files"
    fi

}

# This function will be called if the script status is on enabled mode
apply () {
    for DIR in $(cat /etc/passwd | egrep -v '(root|halt|sync|shutdown)' | awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/bin/false" && $7 !="/nonexistent" ) { print $6 }'); do
    debug "Working on $DIR"
        for FILE in $DIR/.netrc; do
            if [ ! -h "$FILE" -a -f "$FILE" ]; then
                has_file_correct_permissions $FILE $PERMISSIONS
                if [ $FNRET = 0 ]; then
                    ok "$FILE has correct permissions"
                else
                    warn "$FILE has not $PERMISSIONS permissions set"
                    chmod 600 $FILE
                fi
            fi
        done
    done
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ ! -r /etc/default/cis-hardenning ]; then
    echo "There is no /etc/default/cis-hardenning FILE, cannot source CIS_ROOT_DIR variable, aborting"
    exit 128
else
    . /etc/default/cis-hardenning
    if [ -z $CIS_ROOT_DIR ]; then
        echo "No CIS_ROOT_DIR variable, aborting"
    fi
fi 

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
[ -r $CIS_ROOT_DIR/lib/main.sh ] && . $CIS_ROOT_DIR/lib/main.sh
