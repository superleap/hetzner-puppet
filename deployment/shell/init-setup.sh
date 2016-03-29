#!/usr/bin/env bash

VAGRANT_CORE_FOLDER=$(echo "$1")
VAGRANT_DOT_FILES_FOLDER="${VAGRANT_CORE_FOLDER}/files/dot"
SSH_USERNAME=$(echo "$2")

# Print awesome company logo
cat "${VAGRANT_CORE_FOLDER}/files/logo.txt"
printf "\n\n"

# Dot files
if [[ -d "${VAGRANT_DOT_FILES_FOLDER}" ]]; then
    cp -r ${VAGRANT_DOT_FILES_FOLDER}/.[a-zA-Z0-9]* /home/${SSH_USERNAME}
    chown -R ${SSH_USERNAME} /home/${SSH_USERNAME}/.[a-zA-Z0-9]*

    printf "Installed dot files\n"

    touch '/.leap/installed.dot'
else
    printf "The dot files folder doesn't exist, nothing to install\n"
fi

# Always use r10k to check puppetfile modules and install them
# No automatic dependency handling as far as I know
cd "${1}/puppet"
/opt/puppetlabs/puppet/bin/r10k puppetfile install -v
