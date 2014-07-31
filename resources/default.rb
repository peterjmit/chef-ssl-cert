actions :create, :delete
default_action :create

attribute :domain, :kind_of => String, :name_attribute => true
attribute :combine, :kind_of => [TrueClass, FalseClass], :default => node[:ssl_cert][:combined]

attribute :data_bag_name, :kind_of => String, :default => node[:ssl_cert][:data_bag_name]
attribute :data_bag_item, :kind_of => String
attribute :cert_data_bag_key, :kind_of => String, :default => node[:ssl_cert][:cert_data_bag_key]
attribute :key_data_bag_key, :kind_of => String, :default => node[:ssl_cert][:key_data_bag_key]
attribute :chain_data_bag_key, :kind_of => String, :default => node[:ssl_cert][:chain_data_bag_key]

def data_bag_item(arg=nil)
  if arg.nil? and @data_bag_item.nil?
    set_or_return(:data_bag_item, domain.gsub('.', '_'), :kind_of => String)
  else
    set_or_return(:data_bag_item, arg, :kind_of => String)
  end
end

def key_path
  "#{node[:ssl_cert][:key_dir]}/#{domain}.key"
end

def cert_path
  "#{node[:ssl_cert][:cert_dir]}/#{domain}.crt"
end

def ca_bundle_path
  combine ? "#{node[:ssl_cert][:cert_dir]}/#{domain}.ca-bundle" : nil
end

def combined_pem_path
  combine ? "#{node[:ssl_cert][:cert_dir]}/#{domain}.pem" : nil
end
