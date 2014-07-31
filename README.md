# SSL Cert Cookbook

Provide management of SSL certificates and keys via a custom LWRP.


## Requirements

### Cookbooks

This cookbook is dependent on [chef-vault][1] for installation of the chef-vault
gem

### Platforms

This cookbook should work on any system/platform that is supported by Chef. It has
been tested on CentOS 6.5

## Resources

### ssl_cert

Create an SSL certificate. By default the common name (domain) is taken from the
resource name, and the certificate/key files are loaded from `chef-vault`

#### Actions

  * `:create` - _Default action_. Creates or updates the certificate files
  * `:delete` - Deletes the certificate files

#### Attributes

  * `domain` - _Name attribute_. Server name or Common Name for the certificate.
    Generated files use this attribute for the file names. Unless a `data_bag_item`
    attribute is provided this will be used as the base for the data bag item name.
  * `combine` - _Default true_. If false the resource will not attempt to generate
    files containing the combined SSL chain/root certificates
  * `data_bag_name` - _Default_ `node[:ssl_cert][:data_bag_name]`.
  * `data_bag_item` - _Default ssl_cert[domain]_.
  * `cert_data_bag_key` - _Default_ `node[:ssl_cert][:cert_data_bag_key]`.
  * `key_data_bag_key` - _Default_ `node[:ssl_cert][:key_data_bag_key]`.
  * `chain_data_bag_key` - _Default_ `node[:ssl_cert][:chain_data_bag_key]`.


## Attributes

The following attributes are set by default

```ruby
default[:dev_mode] = false
default[:ssl_cert][:combined] = true

default[:ssl_cert][:data_bag_name] = 'ssl-vault'
default[:ssl_cert][:cert_data_bag_key] = 'cert'
default[:ssl_cert][:key_data_bag_key] = 'key'
default[:ssl_cert][:chain_data_bag_key] = 'chain'

# debian/ubuntu
default[:ssl_cert][:key_dir] = '/etc/ssl/private'
default[:ssl_cert][:cert_dir] = '/etc/ssl/certs'
# rhel/fedora
default[:ssl_cert][:key_dir] = '/etc/pki/tls/private'
default[:ssl_cert][:cert_dir] = '/etc/pki/tls/certs'
# Other
default[:ssl_cert][:key_dir] = '/etc'
default[:ssl_cert][:cert_dir] = '/etc'
```

## Recipes

  * default - includes and installs/requires the `chef-vault` gem

## Usage examples

### Basic example

Create data bag `ssl-vault` with item `example_com` containing the following
data:

_note New lines in certificates should be saved as `\n`. Chained certificates
will appear in order provided by the data bag.

```json
{
  "key": "-----BEGIN RSA PRIVATE KEY-----\n",
  "cert": "-----BEGIN CERTIFICATE-----\n",
  "chain": [
    "-----BEGIN CERTIFICATE-----\n"
  ]
}
```

Call the LWRP in your recipe

```ruby
include_recipe 'ssl_cert::default'

cert = ssl_cert 'example.com' do
  action :create
end

# Access paths to the generated files
cert.key_path # /etc/ssl/private/example.com.key
# For apache users
cert.cert_path # /etc/ssl/certs/example.com.crt
cert.ca_bundle_path # /etc/ssl/certs/example.com.ca-bundle
# For nginx users
cert.combined_pem_path # /etc/ssl/certs/example.com.pem
```

### Full example

The data bag name, item and keys are all configurable. Combining the chain
certificate is also optional.

```json
{
  "my_key": "-----BEGIN RSA PRIVATE KEY-----\n",
  "my_certificate": "-----BEGIN CERTIFICATE-----\n"
}
```

```ruby
cert = ssl_cert 'My Awesome Website SSL certificate' do
  domain 'example.com'
  combine false
  data_bag_name 'my_custom_data_bag_name'
  data_bag_item 'my_custom_data_bag_item'
  cert_data_bag_key 'my_certificate'
  key_data_bag_key 'my_key'
  action :create
end
```

### Testing

Set the node attribute `dev_mode` to true, and the LWRP will load a plain text
data bag. Useful for testing with test kitchen or local development.

## TODO:

  * Add support for encrypted data bags
  * Test suites for supported platforms
  * Add option for LWRP setting node attributes containing SSL file paths

[1]: https://github.com/opscode-cookbooks/chef-vault
