# -*- mode: ruby -*-
Vagrant.require_version '>= 1.6.0'
require 'yaml'
required_plugins = %w(
    vagrant-proxyconf
    vagrant-share
)
required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end
vagrant_platform_base = Vagrant::Util::Platform.platform
if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ vagrant_platform_base) != nil then
    vagrant_platform = 'windows'
elsif (/darwin/ =~ vagrant_platform_base) != nil then
    vagrant_platform = 'mac'
else
    vagrant_platform = 'linux'
end
puts "Vagrant CLI launched from #{vagrant_platform}"

# Variables
dir = File.dirname(File.expand_path(__FILE__))
settings = YAML.load_file("#{dir}/deployment/config.yaml")
data = settings['vagrantfile']

vagrant_home = (ENV['VAGRANT_HOME'].to_s.split.join.length > 0) ? ENV['VAGRANT_HOME'] : "#{ENV['HOME']}/.vagrant.d"
vagrant_dot  = (ENV['VAGRANT_DOTFILE_PATH'].to_s.split.join.length > 0) ? ENV['VAGRANT_DOTFILE_PATH'] : "#{dir}/.vagrant"
ssh_username = !data['ssh']['username'].nil? ? data['ssh']['username'] : 'vagrant'

# Local box settings
Vagrant.configure('2') do |config|
    # Configure box based on ${settings}
    config.vm.box     = "#{data['vm']['box']}"
    config.vm.box_url = "#{data['vm']['box_url']}"

    if data['vm']['hostname'].to_s.strip.length != 0
      config.vm.hostname = "#{data['vm']['hostname']}"
    end

    if data['vm']['network']['private_network'].to_s != ''
      config.vm.network 'private_network', ip: "#{data['vm']['network']['private_network']}"
    end

    if data['vm']['network']['public_network'].to_s != ''
      config.vm.network 'public_network'
      if data['vm']['network']['public_network'].to_s != '1'
        config.vm.network 'public_network', ip: "#{data['vm']['network']['public_network']}"
      end
    end

    data['vm']['network']['forwarded_port'].each do |i, port|
      if port['guest'] != '' && port['host'] != ''
        config.vm.network :forwarded_port, guest: port['guest'].to_i, host: port['host'].to_i, auto_correct: true
      end
    end

    data['vm']['synced_folder'].each do |i, folder|
      if folder['source'] != '' && folder['target'] != ''
        sync_owner = !folder['owner'].nil? ? folder['owner'] : 'www-data'
        sync_group = !folder['group'].nil? ? folder['group'] : 'www-data'

        if folder['sync_type'] == 'nfs'
          if Vagrant.has_plugin?('vagrant-bindfs')
            config.vm.synced_folder "#{folder['source']}", "/mnt/vagrant-#{i}", id: "#{i}", type: 'nfs'
            config.bindfs.bind_folder "/mnt/vagrant-#{i}", "#{folder['target']}", owner: sync_owner, group: sync_group, perms: "u=rwX:g=rwX:o=rD"
          else
            config.vm.synced_folder "#{folder['source']}", "#{folder['target']}", id: "#{i}", type: 'nfs'
          end
        elsif folder['sync_type'] == 'rsync'
          rsync_args    = !folder['rsync']['args'].nil? ? folder['rsync']['args'] : ['--verbose', '--archive', '-z']
          rsync_auto    = !folder['rsync']['auto'].nil? ? folder['rsync']['auto'] : true
          rsync_exclude = !folder['rsync']['exclude'].nil? ? folder['rsync']['exclude'] : ['.vagrant/']

          config.vm.synced_folder "#{folder['source']}", "#{folder['target']}", id: "#{i}",
            rsync__args: rsync_args, rsync__exclude: rsync_exclude, rsync__auto: rsync_auto, type: 'rsync', group: sync_group, owner: sync_owner
        elsif data['vm']['chosen_provider'] == 'parallels'
          config.vm.synced_folder "#{folder['source']}", "#{folder['target']}", id: "#{i}",
            group: sync_group, owner: sync_owner, mount_options: ['share']
        else
          config.vm.synced_folder "#{folder['source']}", "#{folder['target']}", id: "#{i}",
            group: sync_group, owner: sync_owner, mount_options: ['dmode=775', 'fmode=774']
        end
      end
    end

    config.vm.usable_port_range = (data['vm']['usable_port_range']['start'].to_i..data['vm']['usable_port_range']['stop'].to_i)

    unless ENV.fetch('VAGRANT_DEFAULT_PROVIDER', '').strip.empty?
      data['vm']['chosen_provider'] = ENV['VAGRANT_DEFAULT_PROVIDER'];
    end

    if !data['ssh']['host'].nil?
      config.ssh.host = "#{data['ssh']['host']}"
    end
    if !data['ssh']['port'].nil?
      config.ssh.port = "#{data['ssh']['port']}"
    end
    if !data['ssh']['username'].nil?
      config.ssh.username = "#{data['ssh']['username']}"
    end
    if !data['ssh']['guest_port'].nil?
      config.ssh.guest_port = data['ssh']['guest_port']
    end
    if !data['ssh']['shell'].nil?
      config.ssh.shell = "#{data['ssh']['shell']}"
    end
    if !data['ssh']['keep_alive'].nil?
      config.ssh.keep_alive = data['ssh']['keep_alive']
    end
    if !data['ssh']['forward_agent'].nil?
      config.ssh.forward_agent = data['ssh']['forward_agent']
    end
    if !data['ssh']['forward_x11'].nil?
      config.ssh.forward_x11 = data['ssh']['forward_x11']
    end
    if !data['vagrant']['host'].nil?
      config.vagrant.host = data['vagrant']['host'].gsub(':', '').intern
    end

    # Configure providers

    # Provision
    config.vm.provision :shell, :inline => "sed -i -e 's/\r$//' /vagrant/deployment/shell/*.sh"

    # config.vm.provision 'shell' do |s|
    #   s.path = 'deployment/shell/initial-setup.sh'
    #   s.args = '/vagrant/deployment'
    # end

    # config.vm.provision 'shell' do |kg|
    #  kg.path = 'puphpet/shell/ssh-keygen.sh'
    #  kg.args = "#{ssh_username}"
    # end

    # config.vm.provision :shell, :path => 'puphpet/shell/install-puppet.sh'
end
