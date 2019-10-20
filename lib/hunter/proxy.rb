# frozen_string_literal: true

#
# Standard libraries
#
require 'tempfile'
require 'webrick/httpproxy'

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
    # @param bind_host [String] Bind host
    # @param bind_port [Integer] Bind port
    # @param targeted_hosts [Array<String>] Targeted host
    def initialize(bind_host, bind_port, targeted_hosts = [])
      @server = _init_proxy_server(bind_host, bind_port)
      @targeted_hosts = targeted_hosts
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
      @server.start

      bind_addr = "#{@server.config['BindAddress']}:#{@server.config['Port']}"
      Hunter::Logger.info("proxy server started ... listening on #{bind_addr}")
    rescue StandardError => e
      Hunter::Logger.error(e.message)
    end

    # Shutdown server
    #
    def shutdown
      Hunter::Logger.info('stopping proxy server')
      @server.shutdown
      Hunter::Logger.info('proxy server stopped')
      Hunter::Logger.info("waiting for #{@threads.size} tasks ...")
      @threads.each(&:join)
    end

    private

    # Init web proxy server
    #
    # @param host [String] Bind host
    # @param port [Integer] Bind port
    # @return [WEBrick::HTTPProxyServer] An instance of proxy server
    def _init_proxy_server(host, port)
      handler = proc { |req, res| process(req, res) }
      WEBrick::HTTPProxyServer.new(
        BindAddress: host,
        Port: port,
        ProxyContentHandler: handler,
        AccessLog: [],
        Logger: WEBrick::Log.new(Tempfile.new.path, WEBrick::Log::FATAL)
      )
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
