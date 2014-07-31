# Copied from chef-vault cookbook
def chef_vault_item(bag, item)
  begin
    require 'chef-vault'
  rescue LoadError
    Chef::Log.warn("Missing gem 'chef-vault', use recipe[chef-vault] to install it first.")
  end

  if node[:dev_mode]
    Chef::DataBagItem.load(bag, item)
  else
    ChefVault::Item.load(bag, item)
  end
end

def create_ssl_file(path, content, mode=00600)
  file path do
    owner 'root'
    group 'root'
    mode mode
    content content
    action :create
  end
end

def create_cert_file(path, content)
  create_ssl_file(path, content, 00644)
end

def get_resource_paths
  [
    new_resource.key_path,
    new_resource.cert_path,
    new_resource.ca_bundle_path,
    new_resource.combined_pem_path,
  ]
end

def exists?
  exists = Proc.new { |p| ::File.exists?(p) }
  get_resource_paths.map(&exists).include? true
end

action :create do
  vault_item = chef_vault_item(new_resource.data_bag_name, new_resource.data_bag_item)
  cert_content = vault_item[new_resource.cert_data_bag_key]
  updated = new_resource.updated_by_last_action?

  # create key and certificate files
  key = create_ssl_file(new_resource.key_path, vault_item[new_resource.key_data_bag_key])
  cert = create_cert_file(new_resource.cert_path, cert_content)
  updated ||= key.updated_by_last_action? || cert.updated_by_last_action?

  # Create combined files
  if new_resource.combine
    chain_key = new_resource.chain_data_bag_key

    if !vault_item.key?(chain_key) or vault_item[chain_key].count == 0
      raise "Cannot combine chained certificates in bag \"#{new_resource.data_bag_name}/#{new_resource.data_bag_item}\", none were found"
    end

    chain_certs_content = vault_item[chain_key].join("\n")

    ca_bundle = create_cert_file(new_resource.ca_bundle_path, chain_certs_content)
    combined_pem = create_cert_file(new_resource.combined_pem_path, [cert_content, chain_certs_content].join("\n"))
    updated ||= ca_bundle.updated_by_last_action? || combined_pem.updated_by_last_action?
  end

  new_resource.updated_by_last_action(updated)
end

action :delete do
  if exists?
    Chef::Log.info("Deleting SSL files for #{new_resource.name}")
    updated = new_resource.updated_by_last_action?
    get_resource_paths.each do |path|
      f = file path do
        action :delete
      end
      updated ||= f.updated_by_last_action?
    end
    new_resource.updated_by_last_action(updated)
  end
end
