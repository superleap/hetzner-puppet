**hetzner.development:**

    vagrant up

**hetzner.production:**

    yum -y install git nano
    useradd -m vortex
    echo -e "-----BEGIN RSA PRIVATE KEY-----\nProc-Type: 4,ENCRYPTED\nDEK-Info: DES-EDE3-CBC,51327E11C033701E\n\n27Fxzs1hBj0YBqXv1Jk4GwgCPBeLGomHDQnxOwS97qBtO7aDiTHov2FZXBG6oxve\nWChpWWuAar8zAguqcTETwxGyiD+4L2+BUb0z6Ia/PqgyphPDSMFgfGmZtg8WRH19\n0cTjZ6z040Ih32zSNvkdgd1StjcEcVqg700Cz5USZMGUN4lpiRRrBcsHG8mhuZw+\n8NHuE5DBHwM36WipWXiEITJekZ4URyDzKQYzOuDBjmgAkWKeNIMFGBMExATaj37I\nGs6Tvs80MUJ1Kd19GTWx7odeteZkOTMmy21VAbxdqM7lY7KGr9NlbbzmIlO/BfJT\n6yp/Vjm4IwdrGItlpJdVYB7E916j/0JH/vCQGFftHurfxqwNCr5kAqFpDKBGEay5\nTt8hUIBU2PnILpn+hdArSnMzhUnxE9NjJPfAVOOhIgGML6eq/FwqcUTAwoyU3Bgr\nSw8IDV1smNpUt0G/H4Dr9Dim7cDEaO7l7XOMALVe+u1jTdWcdDLvikCTKgmtrAWk\n6fPO7GifORqOgl0YQjP4up37kLU6Mb7dVsSJiOa01o/vftTa2Rsoi09+ttUg4Oes\nI/b+WYQXYtRnd0Y6tHjY0D7Px0SHn+354ln+WB5Qtv9IqjOhnKOW81TpFeYID9z/\nS3nMJeo3uaMfRItvv2+XzLLzyOQVMInNzhm9Y9EzU/VTYNBUixl8miWncczpoSee\nI5RkWHFOI9HlzDoAt3yJ0fOOu+HIKAizWnKHmhol9/vYKfOgTXrtOhlDNYKw0qOZ\nqGW0Pyf44s6AeDgZH/8xpSDqUsml6DtNn2ANZ2oIv+qssnrVMRFjELMg9YgHrWIJ\noNSp/U13FK8ngGaSelIscSAZz4oSgm4vY83Phe3BrbgHEyDHHTzpzK9Q7c4HOF4b\nrgplV6NXuT90H1nPg1hIraluIVLOOl+NbZdkr8jhygqEfCmdlKP9iIiR1hFXC8JK\nVPdgjYdqgqVzXkU6nSr0fqluJArVyqbv78IxpTv0zFvVEY753aG9O3wjVwln6tO+\nX9qMEBIG1pZFASyRNnLG3cyBIL9au5XjYw4KPGyStGjHahM95CNUhidDcB1GwgVb\nWzKeOoBiEin+FCIXMCkRWpl8sp12nmcT1AF37HTcKt+jZGbjLbQlxNTCBS3d/lzx\nBJI/77Kyd8Y6XD5GbMR8tAYVxNkbwJfr3RAYox4SNZFpPIoAM8eMf8cyHTswQlDA\nbj561SFetGzw5CRwXoRAtHUMxbUyeSqakZAfRVkPRZswjXR3leCAplIp+fwhd7g0\nTJOOkMLKyxbwGoQqlBRZ6UKQNx9yo9GPCQ9k3i2KRb2nfNBiUs1DxebNP8rGd77k\nvj/XDoiuG+UynTD64i9AJiME7tZ2eCLOP1zUJxhp6EPvDMmihgjd8uMqMQYFtMxH\n4RBz0FSmD7TmqFPInC71DrmTZA3HCOwm0//PW59o987Hs/XhjVBhpaRbG7rEz2+h\nJbohha16mbNBDwqP28ObIdi6Xekho67NJ5zGJD/0gBpBzdZDy9M6I4nxduDj9/4e\n+eI0V+05j4CG9eApB3avec73UlKjIqM4Mj5YBAqI7al2S7OGjopXIg==\n-----END RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa
    echo -e "ssh-rsa\nAAAAB3NzaC1yc2EAAAABIwAAAQEA7l5UkZBA2KVgw8hlSFnlF+4PQqNfwYJG19Z0y2IAGRPcOBO2E920di56bsPcgPiCJfQ9A91zfwCAUKGzKIvin5DF5bgTkYWic6xGDYDsiSwf+NowYTdsdnfiCAb6XZxCa2y25DFg+N6+k7N/gSa/WCJ7uOOndPl1cgFij/nU2b808F5Hpih90MmDUozu+/QkJ4cGT6POs8/efLhDzKHAzEyhQIO2t6QPvO/74xh8Wr0die0MpVnhZZ1KCbYrUZZz5HBojQ6bybEwyfgMJUiYU5Ri/ZtVsvzd7PN7NjoT5yS1nXXP31XHOdKY/wRvPEtZQutju7SX2jO84/ieFwtpGQ== root@CentOS-67-64-minimal" >> ~/.ssh/id_rsa.pub
    chmod 0600 ~/.ssh/id_rsa
    git clone git@github.com:superleap/hetzner-puppet.git /vagrant
    chmod +x /vagrant/deployment/shell/*
    /vagrant/deployment/shell/init-setup.sh /vagrant/deployment vortex && FACTER_ssh_username='vortex' FACTER_ssh_superuser='root' FACTER_fqdn='hetzner.production' /opt/puppetlabs/bin/puppet apply --verbose --hiera_config /vagrant/deployment/puppet/hiera.yaml --modulepath /vagrant/deployment/puppet/module --environment production --environmentpath /vagrant/deployment/environment /vagrant/deployment/puppet/manifest/development.pp

