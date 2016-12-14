# Copyright 2016 Sophos Technology GmbH. All rights reserved.
# See the LICENSE.txt file for details.
# Authors: Vincent Landgraf

module Sophos
  class HTTPLogger
    MAX_LINE = 1024

    def initialize(logger)
      @logger = logger
      @buffer = ''
    end

    def <<(msg)
      @buffer << msg
      while (index = @buffer.index("\n"))
        line = @buffer[0..(index - 1)]
        if line.size < MAX_LINE
          @logger.info "[SOPHOS] HTTP: #{line}"
        else
          @logger.info "[SOPHOS] HTTP: #{line[0..MAX_LINE]} ... (cut after #{MAX_LINE})"
        end
        @buffer = @buffer[(index + 1)..-1]
      end
    end
  end

  module Chef
    def self.client(node, log)
      require 'sophos/sg/rest'
      conf = node['sophos']['sg']
      utm = Sophos::SG::REST::Client.new(conf['url'],
                                         fingerprint: conf['fingerprint'])
      utm.logger = HTTPLogger.new(log)
      utm
    end

    def self.split_path(path, sep = '/')
      parts = path.split(sep)
      [parts[0, 2].join(sep), parts[2]]
    end
  end
end
