default['tlg_workstation']['username'] = nil
default['tlg_workstation']['group'] = if node[:platform] == 'darwin'
                                        'staff'
                                      else
                                        node['tlg_workstation']['username']
                                      end

