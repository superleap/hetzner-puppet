#!/usr/bin/env bash

VAGRANT_CORE_FOLDER=$(echo "$1")

cat "${VAGRANT_CORE_FOLDER}/files/logo.txt"
printf "\n"
echo ""

if [[ ! -d '/.leap' ]]; then
    mkdir -p '/.leap'

    printf "Created base /.leap folder\n"
fi

# CentOS comes with tty enabled. Disabling it improves security
if [[ ! -f '/.leap/disabled.tty' ]]; then
    perl -pi'~' -e 's@Defaults(\s+)requiretty@Defaults !requiretty@g' /etc/sudoers

    printf "Disabled tty\n"

    touch '/.leap/disabled.tty'
else
    printf "CentOS tty was already disabled, skipping\n"
fi

# Add repos: RepoForge, Epel, Remi, Webtatic
# This check is redundant in terms of speed but removing it would enable
if [[ ! -f '/.leap/installed.repos' ]]; then
    printf "RepoForge:\n"
    yum -y --nogpgcheck install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm

    printf "Epel:\n"
    yum -y --nogpgcheck install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm

    printf "Remi:\n"
    yum -y --nogpgcheck install http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

    printf "Webtatic:\n"
    yum -y --nogpgcheck install https://mirror.webtatic.com/yum/el6/latest.rpm

    printf "Finished adding repos\n"

    touch '/.leap/installed.repos'
else
    printf "Repos were added already, skipping\n"
fi
