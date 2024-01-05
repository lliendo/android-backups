#!/data/data/com.termux/files/usr/bin/env bash

# This script is intended to be used from Termux. It installs openssh, rsync and cronie.
#
# It will also configure openssh to:
#   * Automatically start when Termux is launched.
#   * Allow you SSH your phone phone using a username/password login.
#
# Optionally the user can allow Termux to access the phone's storage and delete this script
# after finishing.

TERMUX_BOOT="${HOME}/.termux/boot"


cd_running_script_dir() {
    cd "$(dirname "$(readlink -f "$0")")"
}

function install_packages() {
    pkg update && pkg upgrade
    pkg install openssh rsync cronie
}

function configure_ssh() {
    # Generate host keys otherwise the SSH server will refuse to run.
    ssh-keygen -A

    # Allow the SSH server to start automatically.
    mkdir -p "${TERMUX_BOOT}"
    echo -e '#!/data/data/com.termux/files/usr/bin/env bash\n\ntermux-wake-lock\nsshd' > "${TERMUX_BOOT}/start-sshd"
    chmod u+x "${TERMUX_BOOT}/start-sshd"

    # Set a password so you can login SSH with a username.
    echo -e "Set a new password for Termux SSH:"
    passwd
}

function misc_actions() {
    read -p "Allow Termux access your storage [Y/n]? " -r SETUP_TERMUX_STORAGE

    local SETUP_TERMUX_STORAGE="${SETUP_TERMUX_STORAGE:-Y}"

    while [[ ! "${SETUP_TERMUX_STORAGE}" =~ ^[Y|y|N|n]+$ ]]; do
        read -p "Allow Termux access your storage [Y/n]? " -r SETUP_TERMUX_STORAGE
    done

    case "${SETUP_TERMUX_STORAGE}" in
      y|Y )
        echo -e "Running termux-setup-storage"
        termux-setup-storage
        ;;
      n|N )
        ;;
    esac

    read -p "Delete this setup script [y/N]? " -r DELETE_SETUP_SCRIPT

    local DELETE_SETUP_SCRIPT="${DELETE_SETUP_SCRIPT:-n}"

    while [[ ! "${DELETE_SETUP_SCRIPT}" =~ ^[Y|y|N|n]+$ ]]; do
        read -p "Delete this setup script [y/N]? " -r DELETE_SETUP_SCRIPT
    done

    case "${DELETE_SETUP_SCRIPT}" in
      y|Y )
        echo -e "Deleting termux-init.sh"
        rm -f ./termux-init.sh
        ;;
      n|N )
        ;;
    esac
}

function show_info() {
    cat << EOF
        Your SSH login username is: '$(whoami)'.
        SSH startup script is found in: '${TERMUX_BOOT}/start-sshd'.
        Run Termux Boot at least once to register Termux's automatic start and restart your phone.
EOF
}


function main() {
    WORKING_DIR=${PWD}  # Save current path.

    cd_running_script_dir

    install_packages
    configure_ssh
    misc_actions
    show_info

    cd "${WORKING_DIR}"  # Restore path.
}


main
