# Copyright 2016 Sophos Technology GmbH. All rights reserved.
# See the LICENSE.txt file for details.
# Authors: Vincent Landgraf

name 'sophos'
maintainer 'SOPHOS'
maintainer_email 'sophos-iaas-oss@sophos.com'
license 'MIT, SOPHOS proprietary'
description 'Configuration of SOPHOS UTM Appliances'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.3'
gem 'sophos-sg-rest', '~> 0.1'

recipe 'sophos::sg', 'Configuration of SOPHOS UTM SG Appliances (UTM9)'

%w( amazon centos debian fedora freebsd gentoo redhat scientific solaris2 oracle ubuntu windows xcp ).each do |os|
  supports os
end

source_url 'https://github.com/sophos-iaas/chef-sophos-sg' if respond_to?(:source_url)
issues_url 'https://github.com/sophos-iaas/chef-sophos-sg/issues' if respond_to?(:issues_url)

chef_version '>= 11' if respond_to?(:chef_version)
