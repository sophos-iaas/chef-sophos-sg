# Copyright 2016 Sophos Technology GmbH. All rights reserved.
# See the LICENSE.txt file for details.
# Authors: Vincent Landgraf

require 'net/http'
require 'json'
require 'ostruct'
require 'openssl'

module Sophos
  class UTM9RestClient
    VERSION_HEADER = "Ruby (#{RUBY_VERSION})".freeze
    CLIENT_HEADER = "UTM9 client (#{File.basename($PROGRAM_NAME)})".freeze
    HEADER_USER_AGENT = "#{VERSION_HEADER} - #{CLIENT_HEADER}".freeze
    HEADER_ACCEPT = 'application/json'.freeze
    HEADER_CONTENT_TYPE = 'Content-Type'.freeze
    HEADER_ERR_ACK = 'X-Restd-Err-Ack'.freeze
    HEADER_SESSION = 'X-Restd-Session'.freeze
    HEADER_INSERT = 'X-Restd-Insert'.freeze
    HEADER_LOCK_OVERRIDE = 'X-Restd-Lock-Override'.freeze
    DEFAULT_HEADERS = {
      'Accept' => HEADER_ACCEPT,
      'User-Agent' => HEADER_USER_AGENT
    }.freeze
    attr_reader :http, :url

    class Error < StandardError
      attr_reader :request, :response, :body

      def initialize(request, response, body)
        @request = request
        @response = response
        @body = body

        message = response.message
        message << ": #{errors.first.name}" if errors.any?
        reqdesc = "#{request.method} #{request.path} -> #{response.code}"

        super "UTM9: #{message} (#{reqdesc})"
      end

      def errors
        body.is_a?(Array) ? body : []
      end
    end

    def initialize(url, options = {})
      @url = URI(url)
      @http = Net::HTTP.new(@url.host, @url.port)
      if @url.scheme == 'https'
        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        @http.verify_callback = lambda do |preverify_ok, ssl_context|
          if options[:fingerprint]
            # check if the fingerprint is matching (don't respect the chain)
            fingerprint = options[:fingerprint].gsub(/\s|:/, '').downcase
            ssl_context.chain.each do |cert|
              if fingerprint == OpenSSL::Digest::SHA1.new(cert.to_der).to_s
                return true
              end
            end
            false
          else
            # if the certificate is valid and no fingerprint is passed the
            # certificate chain result is determining
            preverify_ok
          end
        end
      end
    end

    def logger=(logger)
      @http.set_debug_output(logger)
    end

    def objects(type)
      get path_objects(type)
    end

    def object(type, ref)
      get path_object(type, ref)
    end

    def create_object(type, attributes, insert = nil)
      post path_objects(type), attributes, insert
    end

    def patch_object(type, ref, attributes)
      patch path_object(type, ref), attributes
    end

    def update_object(type, attributes, insert = nil)
      h = attributes.to_h
      ref = h['_ref'] || h[:_ref]
      raise ArgumentError, "Object _ref must be set! #{h.inspect}" if ref.nil?
      put path_object(type, ref), h, insert
    end

    def destroy_object(type, ref = nil)
      # if ref is not passed, assume object or hash
      if ref.nil?
        if type.is_a? Hash
          ref = type['_ref'] || type[:_ref]
          type = type['_type'] || type[:_type]
        elsif type.respond_to?(:_type) && type.respond_to?(:_ref)
          ref = type._ref
          type = type._type
        else
          raise ArgumentError, 'type must be a string, hash or object with ' \
            ' _ref and _type defined'
        end
      end

      delete path_object(type, ref)
    end

    def nodes
      get nodes_path
    end

    def update_nodes(hash)
      patch nodes_path, hash
    end

    def node(id)
      get nodes_path(id)
    end

    def update_node(id, value)
      put nodes_path(id), value
    end

    def nodes_path(id = nil)
      base = File.join(@url.path, 'nodes') + '/'
      base = File.join(base, id) if id
      base
    end

    def path_object(type, ref)
      File.join(@url.path, 'objects', type, ref)
    end

    def path_objects(type)
      File.join(@url.path, 'objects', type) + '/'
    end

    def get(path)
      do_json_request('GET', path)
    end

    def post(path, data, insert = nil)
      do_json_request('POST', path, data) do |req|
        req[HEADER_CONTENT_TYPE] = HEADER_ACCEPT
        req[HEADER_INSERT] = insert if insert
      end
    end

    def put(path, data, insert = nil)
      do_json_request('PUT', path, data) do |req|
        req[HEADER_CONTENT_TYPE] = HEADER_ACCEPT
        req[HEADER_INSERT] = insert if insert
      end
    end

    def patch(path, data)
      do_json_request('PATCH', path, data) do |req|
        req[HEADER_CONTENT_TYPE] = HEADER_ACCEPT
      end
    end

    def delete(path)
      do_json_request('DELETE', path) do |req|
        req[HEADER_ERR_ACK] = 'all'
      end
    end

    def do_json_request(method, path, body = nil)
      body = json_encode(body) unless body.nil?
      req = request(method, path, body)
      yield req if block_given?
      response = @http.request(req)
      decode_json(response, req)
    end

    def request(method, path, body = nil)
      req = Net::HTTPGenericRequest.new(method, !body.nil?, true, path, DEFAULT_HEADERS)
      req.basic_auth @url.user, @url.password
      req.body = body
      req
    end

    def json_encode(data)
      data.to_json
    end

    def decode_json(response, req)
      body = nil

      if response.body && response.body != ''
        # rubys JSON parse is unable to parse scalar values (number, string,
        # bool, ...) directly, because of this it needs to be wrapped before
        body = JSON.parse('[' + response.body + ']').first
        if body.is_a?(Array) && body.any? && body.first.is_a?(Hash)
          body = body.map { |i| OpenStruct.new(i) }
        elsif body.is_a? Hash
          body = OpenStruct.new(body)
        else
          body
        end
      end

      raise Error.new(req, response, body) if response.code.to_i >= 400

      body
    end
  end
end
