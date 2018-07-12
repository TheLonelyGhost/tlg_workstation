# -*- mode: ruby -*-
# vi: set ft=ruby :

# Comment out the following line if you like living fast and loose with license terms:
raise 'LICENSE TERMS DICTATE THIS VIRTUAL MACHINE MUST ONLY BE RUN ON APPLE HARDWARE' unless /darwin/i =~ RUBY_PLATFORM

Vagrant.configure('2') do |config|
  config.vm.box = 'AndrewDryga/vagrant-box-osx'

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = true
    vb.memory = '4096'
    vb.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')
  end

  config.vm.synced_folder '.', '/vagrant', type: 'rsync', owner: 'vagrant', group: 'staff', rsync__exclude: ['.git/']
  config.vm.provision 'shell', inline: '/ln -s /vagrant/setup.sh /Users/vagrant/setup.sh'
end
