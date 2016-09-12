# Copyright 2016 Sophos Technology GmbH. All rights reserved.
# See the LICENSE.txt file for details.
# Authors: Vincent Landgraf

module Sophos
  module Chef
    def self.client(node, log)
      utm = Sophos::UTM9RestClient.new(node['sophos']['sg']['url'],
              fingerprint: node['sophos']['sg']['fingerprint'])
      logger = Object.new
      logger.instance_variable_set('@log', log)
      def logger.<<(msg)
        return if msg.to_s.strip == ''
        @log.info "[SOPHOS] HTTP: #{msg}"
      end
      utm.logger = logger
      utm
    end

    def self.split_path(path, sep = '/')
      parts = path.split(sep)
      [parts[0, 2].join(sep), parts[2]]
    end
  end
end
