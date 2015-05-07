name             'ssl_cert'
maintainer       'Peter Mitchell'
maintainer_email 'pete@peterjmit.com'
license          'MIT'
description      'Installs/Configures ssl_cert'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{debian ubuntu redhat centos fedora scientific amazon}.each do |os|
  supports os
end

depends 'chef-vault', '~> 1.3'
