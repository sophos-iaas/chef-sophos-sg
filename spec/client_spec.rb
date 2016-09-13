# Copyright 2016 Sophos Technology GmbH. All rights reserved.
# See the LICENSE.txt file for details.
# Authors: Vincent Landgraf

require 'client'
require 'logger'

RSpec.describe Sophos::UTM9RestClient do
  subject do
    client = described_class.new(ENV['UTM_URL'],
                                 fingerprint: ENV['UTM_FINGERPRINT'])
    client.logger = Logger.new('./rest.log')
    client
  end

  context 'implements CRUD operations on objects' do
    it 'can handle regular CRUD' do
      # delete object that might not exist
      subject.destroy_object('network/host', 'REF_NetHos100100')

      # first there is no object
      addresses = subject.objects('network/host').map(&:address)
      expect(addresses).to_not include('10.0.10.0')

      # then it's created
      obj = subject.create_object('network/host', address: '10.0.10.0')

      # that makes it show up in the list
      addresses = subject.objects('network/host').map(&:address)
      expect(addresses).to include('10.0.10.0')

      # the object can be deleted using the _ref
      subject.destroy_object(obj.to_h)

      # recreating the object
      obj = subject.create_object('network/host', address: '10.0.10.0')

      # change the address
      obj.address = '10.10.10.10'
      obj = subject.update_object('network/host', obj)

      # fetching the object again from the database
      obj2 = subject.object('network/host', obj._ref)

      # they are still the same
      expect(obj).to eq(obj2)

      # only change the address
      subject.patch_object('network/host', obj._ref, address: '10.0.10.0')
      expect(subject.object('network/host', obj._ref).address).to eq '10.0.10.0'

      # remove the object at the end
      subject.destroy_object(obj)
    end

    context 'handles errors' do
      it 'produces rest errors' do
        expect do
          subject.create_object('network/host', address: 'test')
        end.to raise_error(Sophos::UTM9RestClient::Error)
      end

      it 'fails on bad api use' do
        expect do
          subject.destroy_object(100_100)
        end.to raise_error(ArgumentError)
      end
    end
  end

  it 'implements node operations' do
    tree = subject.nodes
    expect(tree['acc.server2.port']).to eq(4433)
    subject.update_nodes('acc.server2.port' => 44_331)
    expect(subject.node('acc.server2.port')).to eq(44_331)
    subject.update_node('acc.server2.port', 4433)
    expect(subject.node('acc.server2.port')).to eq(4433)
  end
end
