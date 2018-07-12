#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOH
Usage: $0 [-h|--help]
EOH
}

parse-cli() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        shift
        usage
        exit 0
        ;;
      -g|--group)
        # NOTE: This is not documented because it is very much prone to error
        if ! groups "${USER}" | grep -Fe "$2" &>/dev/null; then
          echo "WARNING: current user is not part of the specified group '$2'" 1>&2
        fi
        grp="$2"
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Unknown flag '$1'" 1>&2
        exit 1
        ;;
      *)
        break
        ;;
    esac
  done
}

__IS_MAC=$(test "$(uname -s)" = "Darwin")

# Default values
if $__IS_MAC; then
  grp="staff"
else
  grp="${USER}"
fi
chef_config_path="${HOME}/.chef"
cache_path="${HOME}/.cache/tlg_workstation"
config_path="${HOME}/.config/tlg_workstation"
chef_client='/opt/chefdk/bin/chef-client'
berks='/opt/chefdk/bin/berks'
git='/opt/chefdk/gitbin/git'

if [ -n "${DEBUG:-}" ]; then
  runlist="recipe[tlg_workstation::noop]"
else
  runlist="recipe[tlg_workstation::default]"
fi

# Override vars above with CLI options
parse-cli "$@"

if [ ! -x "$berks" ] || [ ! -x "$chef_client" ] || [ ! -x "$git" ]; then # Install
  printf 'Installing ChefDK...\n'
  # We're installing ChefDK this way initially so that we can use Bershelf
  curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk
fi
if [ ! -x "$berks" ]; then # Verify
  printf 'The ChefDK berks executable failed to install. Expected %s to exist and be executable\n' "${berks}" 1>&2
  exit 1
fi
if [ ! -x "$chef_client" ]; then # Verify
  printf 'The ChefDK chef-client executable failed to install. Expected %s to exist and be executable\n' "${chef_client}" 1>&2
  exit 1
fi
if [ ! -x "$git" ]; then
  printf 'The ChefDK git executable failed to install. Expected %s to exist and be executable\n' "${git}" 1>&2
  exit 1
fi

printf 'Setting up our temporary workspace for Chef\n'

# Scaffold our workstation-provisioning mono-repo directory structure
mkdir -p "${config_path}"/{data_bags,environments,nodes,roles}
mkdir -p "${cache_path}"/{chef_backup,chef_cache,cookboks}
mkdir -p "${chef_config_path}"

# This is a workaround for using git until we run chef-client to install git (and xcode-tools, for macOS)
export PATH="/opt/chefdk/gitbin:$PATH"

# Configuration file used by chef-client for provisioning this workstation
cat <<EOH > "${chef_config_path}/client.rb"
local_mode true
chef_zero.enabled true
exit_status :enabled
json_attribs File.expand_path('node_attributes.json', ::File.dirname(__FILE__))

chef_repo_path '${cache_path}'
cookbook_path File.expand_path('cookbooks', '${cache_path}')
data_bag_path File.expand_path('data_bags', '${config_path}')
environment_path File.expand_path('environments', '${config_path}')
node_path File.expand_path('nodes', '${config_path}')
role_path File.expand_path('roles', '${config_path}')

file_cache_path File.expand_path('chef_cache', '${cache_path}')
file_backup_path File.expand_path('chef_backup', '${cache_path}')
EOH

# Cookbook attribute data
if [ ! -e "${chef_config_path}/node_attributes.json" ]; then
  cat <<EOH > "${chef_config_path}/node_attributes.json"
{
  "tlg_workstation": {
    "username": "${USER}",
    "group": "${grp}"
  }
}
EOH
fi

# Berksfile for handling dependencies (in case multiple cookbooks downloaded)
cat <<EOH > "${config_path}/Berksfile.rb"
source ENV.fetch('CHEF_SUPERMARKET_URL', 'https://supermarket.chef.io')

cookbook 'tlg_workstation', github: 'thelonelyghost/tlg_workstation', branch: '${BRANCH:-master}'
EOH

# Resolve dependencies
if [ -e "${config_path}/Berksfile.rb.lock" ]; then rm -f "${config_path}/Berksfile.rb.lock"; fi
printf 'Downloading provisioning cookbook and its dependencies...\n'
"$berks" vendor "${config_path}/cookbooks" --berksfile "${config_path}/Berksfile.rb"

# Run chef-client to provision the workstation
printf 'Provisioning workstation...\n'
sudo "$chef_client" --once --config "${chef_config_path}/client.rb" --runlist "$runlist"

printf 'Done!\n'

printf 'If you would like to run this again, everything is all set, you just need to run %s\n' "\`chef-client'"
