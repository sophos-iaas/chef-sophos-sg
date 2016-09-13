# Copyright 2016 Sophos Technology GmbH. All rights reserved.
# See the LICENSE.txt file for details.
# Authors: Vincent Landgraf

name 'sophos'
maintainer 'SOPHOS'
maintainer_email 'nsg-eng-team-verdi@sophos.com'
license 'MIT'
description 'Configuration of SOPHOS Appliances'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'

recipe 'sophos::sg', 'Configuration of SG Appliances (UTM9)'

%w( amazon centos debian fedora freebsd gentoo redhat scientific solaris2 oracle ubuntu windows xcp ).each do |os|
  supports os
end

source_url 'https://github.com/sophos-iaas/sg-chef' if respond_to?(:source_url)
issues_url 'https://github.com/sophos-iaas/sg-chef/issues' if respond_to?(:issues_url)

chef_version '>= 11' if respond_to?(:chef_version)
