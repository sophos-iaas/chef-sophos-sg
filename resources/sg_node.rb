# Copyright 2016 Sophos Technology GmbH. All rights reserved.
# See the LICENSE.txt file for details.
# Authors: Vincent Landgraf

property :path, String, name_property: true
property :value

default_action :set
allowed_actions :set

load_current_value do
  value Sophos::Chef.client(node, Chef::Log).node(path)
end

action :set do
  converge_if_changed do
    Chef::Log.info "[SOPHOS] Updating node #{path} -> #{value}"
    Sophos::Chef.client(node, Chef::Log).update_node(path, value)
  end
end
