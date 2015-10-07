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

# Add repos: RepoForge, Epel, Remi, Webtatic
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

# Install puppet 4.2 from puppetlabs repo
if [[ ! -f '/.leap/installed.puppet' ]]; then
    yum -y --nogpgcheck install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
    yum -y install puppet-agent
    /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
    service puppet restart
    printf "Finished installing puppet\n"

    /opt/puppetlabs/puppet/bin/gem install r10k
    printf "Finished installing r10k\n"

    if [[ -f '/root/.bashrc' ]] && ! grep -q 'export PATH=/opt/puppetlabs/bin:$PATH' /root/.bashrc; then
        echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /root/.bashrc
    fi

    if [[ -f '/etc/profile' ]] && ! grep -q 'export PATH=/opt/puppetlabs/bin:$PATH' /etc/profile; then
        echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /etc/profile
    fi

    source ~/.bashrc

    touch '/.leap/installed.puppet'
else
    printf "Puppet installed already, skipping\n"
fi

if [[ ! -f '/.leap/installed.modules' ]]; then
    cd "${1}/puppet"
    /opt/puppetlabs/puppet/bin/r10k puppetfile install -v

    touch '/.leap/installed.modules'
else
    printf "Puppet modules installed, skipping\n"
fi
