#!/data/data/com.termux/files/usr/bin/env bash

# This script is intended to be used from Termux. It backups a directory
# from your Android phone to a remote host using `rsync` and `ssh`.
#
# Usage:
#
#   ./termux-backup SOURCE_PATH USERNAME@HOST:DESTINATION_PATH ID_RSA_PATH
#
# Example:
#
#   ./termux-backup.sh $HOME/storage backup@redstar.local: id_rsa

SOURCE=$1
DESTINATION=$2
ID_RSA=$3


function split_string {
    local STRING=$1
    local SEPARATOR=$2
    local INDEX=$3

    echo "${STRING}" | cut -d "${SEPARATOR}" -f "${INDEX}"
}

function string_contains {
    local STRING=$1
    local SUBSTRING=$2

    if [[ "${STRING}" == *"${SUBSTRING}"* ]]; then
        echo "yes"
    else
        echo "no"
    fi
}

function get_ssh_login {
    local DESTINATION=$1
    local SSH_LOGIN="${DESTINATION}"

    if [[ $(string_contains "${DESTINATION}" ":") == "yes" ]]; then
        SSH_LOGIN=$(split_string "${DESTINATION}" ":" 1)
    fi

    echo "${SSH_LOGIN}"
}

function valid_ssh {
    local DESTINATION=$1
    local ID_RSA=$2

    local VALID_SSH="no"
    local SSH_LOGIN=$(get_ssh_login "${DESTINATION}")

    if [[ -n "${SSH_LOGIN}" ]] && [[ -f "${ID_RSA}" ]]; then
        ssh -q -i "${ID_RSA}" "${SSH_LOGIN}" exit

        local SSH_RESULT=$?

        if [[ "${SSH_RESULT}" == 0 ]]; then
            VALID_SSH="yes"
        fi
    fi

    echo "${VALID_SSH}"
}

function backup {
    local SOURCE=$1
    local DESTINATION=$2
    local ID_RSA=$3

    local VALID_SSH=$(valid_ssh "${DESTINATION}" "${ID_RSA}")
    local RSYNC_OPTIONS=(-av --no-perms --copy-links --stats)

    if [[ "${VALID_SSH}" == "yes" ]]; then
        RSYNC_OPTIONS+=(-e "ssh -i ${ID_RSA}")
    fi

    rsync "${RSYNC_OPTIONS[@]}" "${SOURCE}" "${DESTINATION}"
}


function main {
    local SOURCE=$1
    local DESTINATION=$2
    local ID_RSA=$3

    backup "${SOURCE}" "${DESTINATION}" "${ID_RSA}"
}


main "${SOURCE}" "${DESTINATION}" "${ID_RSA}"
