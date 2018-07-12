# encoding: utf-8

# InSpec control for tlg_workstation::default
#
# The InSpec reference, with examples and extensive documenation, can be found at the following URLs:
#   - https://www.inspec.io/docs/reference/resources/
#   - https://www.inspec.io/docs/reference/profiles/

username = attribute('username', default: 'vagrant')
my_user = user(username)

control 'tlg_workstation-default-baseline' do
  title 'Baseline for tlg_workstation::default'
  desc <<-EOH
    Confirmation of the end-state after executing recipe[tlg_workstation::default]
  EOH
  impact 0.5

  describe my_user do
    it { should exist }
  end

  describe directory(my_user.home) do
    it { should exist }
  end
end
