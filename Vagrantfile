# -*- mode: ruby -*-
# vi: set ft=ruby :


require 'yaml'


DEFAULT_CONFIGS = YAML.load_file 'conf/default_configs.yaml'
VAGRANTFILE_API_VERSION = DEFAULT_CONFIGS['default_config']['vagrantfile_api_version']
ENV["LC_ALL"] = DEFAULT_CONFIGS['default_config']['lc_all']

BOX_CONFIGS = YAML.load_file 'conf/box_configs.yaml'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  BOX_CONFIGS.each do |env|
    config.vm.define env['name'] do |box|
      box.vm.box         = env['box']
      box.vm.hostname    = env['hostname']
      box.vm.box_version = env['box_version'] 
      box.vm.synced_folder env['dir_host'], env['dir_guest']
      
      box.vm.provider env['box_provider'] do |vb|
        vb.gui    = env['vmgui']
        vb.cpus   = env['cpu']
        vb.memory = env['ram']
      end 
      ### Requirements: vagrant plugin install vagrant-disksize
      box.disksize.size = env['disk']
      box.vm.network "forwarded_port", guest: env['guest_port'], host: env['host_port'],  host_ip: "127.0.0.1"
      box.vm.provision "shell", path: env['file_provision']
    end
  end
end
