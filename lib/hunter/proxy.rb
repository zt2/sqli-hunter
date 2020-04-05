# frozen_string_literal: true

#
# Standard libraries
#
require 'rubygems'
require 'bundler'

Bundler.setup

require 'ritm'

#
# Custom libraries
#
require_relative 'logger'

module Hunter
  #
  # HTTP monitor
  #
  class Proxy
    # Setup a proxy server
    #
    # @param opts [Hash]
    # @option opts [String] :bind_host Bind host
    # @option opts [Integer] :bind_port Bind port
    # @option opts [Array<String>] :targets Targets
    # @option opts [String] :ca_crt_path Path for CA crt
    # @option opts [String] :ca_key_path Path for CA key
    def initialize(opts)
      _init_proxy_server(opts[:bind_host], opts[:bind_port], opts[:ca_crt_path],
                         opts[:ca_key_path])
      @targeted_hosts = opts[:targets]
      @targeted_methods = %w[GET POST]
      @ignore_uri = %w[.css .js .jpg .jpeg .gif .png .html .htm .swf]
      @threads = []
    end

    # Process HTTP request and response
    #
    # @param req [WEBrick::HTTPRequest] HTTP request
    # @param res [WEBrick::HTTPResponse] HTTP response
    def process(req, res)
      return if _ignore?(req, res)

      @threads << Thread.new { Hunter::SQLMAP.run(req) }
    end

    # Start monitor
    #
    def start
      conf = Ritm::GLOBAL_SESSION.conf
      bind_addr = "#{conf.proxy[:bind_address]}:#{conf.proxy[:bind_port]}"
      Hunter::Logger.info("Proxy server started ... listening on #{bind_addr}")

      Ritm.start
    rescue StandardError => e
      Hunter::Logger.error(e.message)
    end

    # Shutdown server
    #
    def shutdown
      Hunter::Logger.info('Stopping proxy server')
      Ritm.shutdown
      Hunter::Logger.info('Proxy server stopped')
      Hunter::Logger.info("Waiting for #{@threads.size} tasks ...")
      @threads.each(&:join)
    end

    private

    # Init web proxy server
    #
    # @param host [String] Bind host
    # @param port [Integer] Bind port
    # @param ca_crt_path [String] Path for CA crt
    # @param ca_key_path [String] Path for CA key
    # @return [WEBrick::HTTPProxyServer] An instance of proxy server
    def _init_proxy_server(host, port, ca_crt_path, ca_key_path)
      Ritm.configure do
        proxy[:bind_address] = host
        proxy[:bind_port] = port
        ssl_reverse_proxy.ca[:pem] = ca_crt_path
        ssl_reverse_proxy.ca[:key] = ca_key_path
      end

      Ritm.on_response { |req, res| process(req, res) }
    end

    # Decide whether we should ignore this request
    #
    # @param req [WEBrick::HTTPRequest]
    # @param res [WEBrick::HTTPResponse]
    # @return [Boolean]
    def _ignore?(req, res)
      return true unless @targeted_methods.include?(req.request_method)

      unless @targeted_hosts.empty?
        return true unless @targeted_hosts.include?(req.host)
      end

      return true if req.request_uri.path.end_with?(*@ignore_uri)

      return true if res.status != 200

      false
    end
  end
end
