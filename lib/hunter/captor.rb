module Hunter
  class Captor
    def initialize(port: 8888)
      @insert_req = [/\.css$/, /\.js$/, /\.jpg$/, /\.jpeg$/, /\.gif$/, /\.png$/, /\.bmp$/, /\.html$/, /\.htm$/, /\.swf/]

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

    def filter(req, _)
      @insert_req.each do |path|
        unless req.request_uri.path.downcase =~ path
          # Save to /tmp/
          save_path = "/tmp/#{SecureRandom.hex(16)}"
          File.write(save_path, req.to_s)

          Hunter::MUTEX.synchronize {
            Hunter::REQUESTS << save_path
          }
          return
        end
      end
    end

    def start
      @proxy.start
    end
  end
end