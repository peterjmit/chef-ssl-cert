default[:dev_mode] = false
default[:ssl_cert][:combined] = true

default[:ssl_cert][:data_bag_name] = 'ssl-vault'
default[:ssl_cert][:cert_data_bag_key] = 'cert'
default[:ssl_cert][:key_data_bag_key] = 'key'
default[:ssl_cert][:chain_data_bag_key] = 'chain'

case node[:platform_family]
when 'debian', 'ubuntu'
  default[:ssl_cert][:key_dir] = '/etc/ssl/private'
  default[:ssl_cert][:cert_dir] = '/etc/ssl/certs'
when 'rhel', 'fedora'
  default[:ssl_cert][:key_dir] = '/etc/pki/tls/private'
  default[:ssl_cert][:cert_dir] = '/etc/pki/tls/certs'
else
  default[:ssl_cert][:key_dir] = '/etc'
  default[:ssl_cert][:cert_dir] = '/etc'
end
