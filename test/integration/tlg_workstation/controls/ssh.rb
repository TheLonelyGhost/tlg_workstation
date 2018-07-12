# encoding: utf-8

# InSpec control for tlg_workstation::ssh
#
# The InSpec reference, with examples and extensive documenation, can be found at the following URLs:
#   - https://www.inspec.io/docs/reference/resources/
#   - https://www.inspec.io/docs/reference/profiles/

username = attribute('username', default: 'vagrant')
my_user = user(username)

control 'tlg_workstation-ssh-baseline' do
  title 'Baseline for tlg_workstation::ssh'
  desc <<-EOH
    Confirmation of the end-state after executing recipe[tlg_workstation::ssh]
  EOH
  impact 0.5

  describe directory("#{my_user.home}/.ssh") do
    it { should exist }
    it { should be_owned_by username }
    it { should be_executable.by_user(username) }
    it { should be_readable.by_user(username) }
  end

  describe file("#{my_user.home}/.ssh/config") do
    it { should exist }
    it { should be_owned_by username }
    it { should be_readable.by_user(username) }
  end
end
