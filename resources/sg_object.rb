# Copyright 2016 Sophos Technology GmbH. All rights reserved.
# See the LICENSE.txt file for details.
# Authors: Vincent Landgraf

ANY_POSITION = -1
POSITION_TABLE = Hash.new { |h, k| h[k] = 0 }

property :path, String, name_property: true
property :insert_to_node, String, default: ''
property :insert_position, default: ANY_POSITION
property :attributes, Hash, default: {}

default_action :create
allowed_actions :create, :delete, :change

load_current_value do |desired|
  utm = Sophos::Chef.client(node, Chef::Log)
  _, ref = Sophos::Chef.split_path(path)
  begin
    # Check the node
    if desired.property_is_set?(:insert_to_node)
      node = utm.node(desired.insert_to_node)

      # set the node, since we are included
      if node.include?(ref)
        insert_to_node desired.insert_to_node

        if desired.insert_position == ANY_POSITION # any position is fine
          insert_position ANY_POSITION
        elsif desired.property_is_set?(:insert_position)
          insert_position node.index(ref)
        end
      end
    end

    # take the remote state and strip it to the values the user
    # specifies in his recipes (Note: might be stale if users remove attributes)
    server_hash = utm.object(*Sophos::Chef.split_path(path)).to_h
    reduced_to_local_set = {}
    desired.attributes.keys.each do |key|
      reduced_to_local_set[key] = server_hash[key]
    end
    attributes reduced_to_local_set
  rescue Sophos::SG::REST::Error => ex
    return current_value_does_not_exist! if ex.response.code.to_i == 404
    raise ex
  end
end

action :create do
  converge_if_changed do
    utm = Sophos::Chef.client(node, Chef::Log)
    type, ref = Sophos::Chef.split_path(path)
    Chef::Log.info "[SOPHOS] Creating object #{ref} (#{type})"
    if property_is_set?(:insert_to_node)
      pos = insert_position == ANY_POSITION ? '' : " #{insert_position}"
      insert = "#{insert_to_node}#{pos}"
    end
    obj = utm.update_object(type, attributes.merge(_ref: ref), insert)
    if obj._ref != ref
      utm.destroy_object(obj)
      raise ArgumentError, 'REF had invalid format, only use [a-Z0-9]!'
    end
  end
end

action :change do
  converge_if_changed do
    utm = Sophos::Chef.client(node, Chef::Log)
    type, ref = Sophos::Chef.split_path(path)
    Chef::Log.info "[SOPHOS] Creating object #{ref} (#{type})"
    utm.patch_object(type, ref, attributes)
  end
end

action :delete do
  utm = Sophos::Chef.client(node, Chef::Log)
  type, ref = Sophos::Chef.split_path(path)
  Chef::Log.info "[SOPHOS] Deleting object #{ref} (#{type})"
  utm.destroy_object(type, ref)
end

def auto_position(name)
  val = POSITION_TABLE[name]
  POSITION_TABLE[name] += 1
  val
end

def auto_insert_to_node(name)
  insert_to_node name
  insert_position auto_position(name)
end
