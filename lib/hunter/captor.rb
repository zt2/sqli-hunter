module Hunter
  class Captor < Hunter::Common
    def initialize(port: 8888, save_path: '/tmp')
      super()
      @save_path = File.realpath(save_path)
      @filter_file = %w(.css .js .jpg .jpeg .gif .png .bmp .html .htm .swf)
      @filter_code = [/4\d{2}/]

      handler = proc do |req, res|
        filter(req, res)
      end

      @proxy = WEBrick::HTTPProxyServer.new(
        Port: port,
        ProxyContentHandler: handler,
        AccessLog: [],
        Logger: WEBrick::Log.new('./sqli-hunter.log', WEBrick::Log::INFO)
      )

      print_msg("[#{Time.now.strftime('%T')}] Proxy server started... listening on port #{port}", :notice, 1)
    end

    def filter(req, res)
      raw_req = req.raw_header.join.chomp
      raw_req << "\r\n#{req.body}" unless req.body.nil?

      header = res.header
      raw_res = JSON.pretty_generate header

      print_msg("[#{Time.now.strftime('%T')}] #{req.request_line.chomp}", :notice, 2)
      print_msg("[#{Time.now.strftime('%T')}] Request:\r\n#{raw_req}", :notice, 3)
      print_msg("[#{Time.now.strftime('%T')}] Response:\r\n#{raw_res}", :notice, 3)

      uri = Addressable::URI.parse(req.request_uri)
      @filter_file.each do |static_file|
        return if uri.extname.downcase.eql? static_file
      end

      @filter_code.each do |error_code|
        return if res.status.to_s =~ error_code
      end

      # Save request
      save_path = File.join(@save_path, SecureRandom.hex(16))
      File.write(save_path, req.to_s)
      print_msg("[#{Time.now.strftime('%T')}] Saving to #{save_path}", :notice, 2)

      @@mutex.synchronize do
        @@request_queue << save_path
      end
          end

    def start
      @proxy.start
    end
  end
end
