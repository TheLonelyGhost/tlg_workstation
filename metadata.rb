name 'tlg_workstation'
maintainer 'David Alexander'
maintainer_email 'opensource@thelonelgyhost.com'
license 'MIT'
description "Installs/Configures David's preferred workstation settings"
long_description "Installs/Configures David's preferred workstation settings"
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://github.com/thelonelyghost/tlg_workstation/issues'
source_url 'https://github.com/thelonelyghost/tlg_workstation'

recipe 'tlg_workstation::default', 'Default recipe for installing and configuring tlg_workstation'

supports 'ubuntu'
supports 'macos'
