module Hunter
  class Captor
    def initialize(port: 8888)
      @filter_file = %w|.css .js .jpg .jpeg .gif .png .bmp .html .htm .swf|
      @filter_code = [/4\d{2}/]

      handler = proc do |req, res|
        filter(req, res)
      end

      @proxy = WEBrick::HTTPProxyServer.new(
          Port: port,
          ProxyContentHandler: handler,
          AccessLog: [],
          Logger: WEBrick::Log::new('./sqli-hunter.log', WEBrick::Log::INFO)
      )

      puts "#{Hunter.info('[*] Proxy server started... listening on port ' + port.to_s)}"
    end

    def filter(req, res)
      uri = Addressable::URI.parse(req.request_uri)
      @filter_file.each do |static_file|
        if uri.extname.downcase.eql? static_file
          return
        end
      end

      @filter_code.each do |error_code|
        if res.status.to_s =~ error_code
          return
        end
      end

      # Save to /tmp/
      save_path = "/tmp/#{SecureRandom.hex(16)}"
      File.write(save_path, req.to_s)

      Hunter::MUTEX.synchronize {
        Hunter::REQUESTS << save_path
      }
      return
    end

    def start
      @proxy.start
    end
  end
end