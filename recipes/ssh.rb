#
# Cookbook:: tlg_workstation
# Recipe:: ssh
#
# Copyright:: 2018, David Alexander
# License:: MIT
username = node['tlg_workstation']['username']
groupname = node['tlg_workstation']['group']
home = ::File.expand_path("~#{username}/")

directory "#{home}/.ssh" do
  mode '0700'
  owner username
  group groupname

  action :create
end

template "#{home}/.ssh/config" do
  source 'ssh_config.erb'

  mode '0644'
  owner username
  group groupname

  action :create
end
