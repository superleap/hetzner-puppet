**hetzner.development:**

    vagrant up

**hetzner.production:**

    yum install git
    ssh-keygen
    git clone git@github.com:superleap/hetzner-puppet.git /vagrant
    chmod +x /vagrant/deployment/shell/*
    /vagrant/deployment/shell/init-setup.sh /vagrant/deployment
    FACTER_ssh_username='vortex' FACTER_ssh_superuser='root' FACTER_fqdn='hetzner.production' /opt/puppetlabs/bin/puppet apply --verbose --hiera_config /vagrant/deployment/puppet/hiera.yaml --modulepath /vagrant/deployment/puppet/module --environment production --environmentpath /vagrant/deployment/environment /vagrant/deployment/puppet/manifest/development.pp

