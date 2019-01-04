#
# Cookbook:: tlg_workstation
# Recipe:: ssh
#
# Copyright:: 2018, David Alexander
# License:: MIT
username = node['tlg_workstation']['username']
groupname = node['tlg_workstation']['group']
home = ::File.expand_path("~#{username}/")
tmp_instad = ::File.join(Chef::Config[:file_cache_path], '')

directory '/usr/local'
directory '/usr/local/bin'
directory '/usr/local/share'

git tmp_instad do
  repository 'https://github.com/thelonelyghost/insta.d.git'
  revision 'master'
  action :sync
end

execute 'install_instant.d' do
  command 'make reinstall'
  cwd tmp_instad
end

%w(.ssh/config.d/pre .ssh/config.d .ssh/config.d/post).each do |dir|
  directory "#{home}/#{dir}" do
    recursive true

    mode '0755'
    owner username
    group groupname

    action :create
  end
end

template "#{home}/.ssh/config.d/pre/00_base" do
  source 'ssh_config.erb'

  mode '0644'
  owner username
  group groupname

  action :create_if_missing

  notifies :run, 'execute[ssh_config_compile]', :delayed
end

execute 'ssh_config_compile' do
  command "/usr/local/bin/instant.d '#{home}/.ssh/config.d' '#{home}/.ssh/config'"

  action :nothing
end
