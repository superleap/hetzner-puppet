#!/usr/bin/env bash

VAGRANT_CORE_FOLDER=$(echo "$1")

cat "${VAGRANT_CORE_FOLDER}/files/logo.txt"
printf "\n\n"

if [[ ! -d '/.leap' ]]; then
    mkdir -p '/.leap'

    printf "Created base /.leap folder\n"
fi

# CentOS comes with tty enabled. Disabling it improves security, apparently
if [[ ! -f '/.leap/disabled.tty' ]]; then
    perl -pi'~' -e 's@Defaults(\s+)requiretty@Defaults !requiretty@g' /etc/sudoers

    printf "Disabled tty\n"

    touch '/.leap/disabled.tty'
else
    printf "CentOS tty was already disabled, skipping\n"
fi

# Install puppet 4.2 from puppetlabs repo
if [[ ! -f '/.leap/installed.puppet' ]]; then
    yum -y --nogpgcheck install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
    yum -y install puppet-agent
    /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
    service puppet restart
    printf "Finished installing puppet\n"

    if [[ -f '/root/.bashrc' ]] && ! grep -q 'export PATH=/opt/puppetlabs/bin:$PATH' /root/.bashrc; then
        echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /root/.bashrc
    fi

    if [[ -f '/etc/profile' ]] && ! grep -q 'export PATH=/opt/puppetlabs/bin:$PATH' /etc/profile; then
        echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /etc/profile
    fi

    source ~/.bashrc

    /opt/puppetlabs/puppet/bin/gem install r10k --source http://rubygems.org
    printf "Finished installing r10k\n"

    touch '/.leap/installed.puppet'
else
    printf "Puppet installed already, skipping\n"
fi

# Always use r10k to check puppetfile modules and install them
# No automatic dependency handling as far as I know
cd "${1}/puppet"
/opt/puppetlabs/puppet/bin/r10k puppetfile install -v
