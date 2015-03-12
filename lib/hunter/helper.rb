module Hunter
  class Helper
    def initialize
      @threads = []

      # Common options
      @common_options = OpenStruct.new
      @common_options.proxy_port = 8080
      @common_options.api_host = 'localhost:8775'

      # SQLmap options
      @sqlmap_options = OpenStruct.new
      @sqlmap_options.threads = 5
      @sqlmap_options.smart = false
      @sqlmap_options.tech = 'BEUSTQ'

      @banner =<<EOT

 _____ _____ __    _     _____         _
|   __|     |  |  |_|___|  |  |_ _ ___| |_ ___ ___
|__   |  |  |  |__| |___|     | | |   |  _| -_|  _|
|_____|__  _|_____|_|   |__|__|___|_|_|_| |___|_|
         |__|

      sqlmap api wrapper by ztz (ztz@ztz.me)

EOT
      usage = "Usage: #{$0} [options]"
      OptionParser.new do |opts|
        opts.banner = @banner + usage

        opts.separator ''
        opts.separator 'Common options:'
        opts.on('-s', '--server', 'Act as a Proxy-Server') do
          @common_options.as_proxy_server = true
        end

        opts.on('-p <PORT>', '--port=<PORT>', OptionParser::DecimalInteger, 'Port of the Proxy-Server (default is 8888)') do |port|
          @common_options.proxy_port = port
        end

        opts.on('--api-host=<HOST>', String, 'Host of the sqlmapapi (default is localhost:8775)') do |host|
          @common_options.api_host = host
        end

        opts.on('--version', 'Show version') do
          puts "SQLi-Hunter version: '#{Hunter::VERSION}'"
          exit
        end

        opts.separator ''
        opts.separator 'sqlmap options'

        opts.on('--technique=<TECH>', 'SQL injection techniques to use (default "BEUSTQ")') do |tech|
          @sqlmap_options.tech = tech
        end

        opts.on('--threads=<THREADS>', OptionParser::DecimalInteger, 'Max number of concurrent HTTP(s) requests (default 5)') do |threads|
          @sqlmap_options.threads = threads
        end

        opts.on('--dbms=<DBMS>', 'Force back-end DBMS to this value') do |dbms|
          @sqlmap_options.dbms = dbms
        end

        opts.on('--os=<OS>', 'Force back-end DBMS operating system to this value') do |os|
          @sqlmap_options.os = os
        end

        opts.on('--tamper=<TAMPER>', 'Use given script(s) for tampering injection data') do |tamper|
          @sqlmap_options.tamper = tamper
        end

        opts.on('--level=<LEVEL>', 'Level of tests to perform (1-5, default 1)') do |level|
          @sqlmap_options.level = level
        end

        opts.on('--risk=<RISK>', 'Risk of tests to perform (0-3, default 1)') do |risk|
          @sqlmap_options.risk = risk
        end

        opts.on('--mobile', 'Imitate smartphone through HTTP User-Agent header') do |mobile|
          @sqlmap_options.mobile = mobile
        end

        opts.on('--smart', 'Conduct through tests only if positive heuristic(s)') do |smart|
          @sqlmap_options.smart = smart
        end
      end.parse!

      trap 'INT'  do
        Hunter::TASKS.each { |task| task.delete_file }
        @threads.each { |thr| thr.kill }
      end

      trap 'TERM' do
        Hunter::TASKS.each { |task| task.delete_file }
        @threads.each { |thr| thr.kill }
      end
    end

    def start
      puts @banner

      if @common_options.as_proxy_server
        captor = Hunter::Captor.new(port: @common_options.proxy_port)
        @threads << Thread.new {
          captor.start
        }
      end

      @threads << Thread.new {
        while true
          if Hunter::REQUESTS.empty?
            Thread.pass
            next
          end

          # Recv a request data (save path)
          save_path = Hunter::REQUESTS.pop

          # Create a new task
          task = Hunter::Task.new(@common_options.api_host, save_path)

          unless task.task_id
            puts "[SQLMap Client] Create task error: #{save_path}, retry after 5s"
            Hunter::REQUESTS << save_path
            sleep(5)
            next
          end

          # Set option
          @sqlmap_options.requestFile = save_path
          unless task.option_set(@sqlmap_options.to_h)
            puts "[SQLMap Client] Set option error: #{task.task_id}, retry after 5s"
            Hunter::REQUESTS << save_path
            task.delete
            sleep(5)
            next
          end

          # Run task
          unless task.scan_start
            puts "[SQLMap Client] Start scan error: #{task.task_id}, retry after 5s"
            Hunter::REQUESTS << save_path
            task.delete
            sleep(5)
            next
          end

          Hunter::MUTEX.synchronize {
            Hunter::TASKS << task
          }
        end
      }

      @threads << Thread.new {
        while true
          delete_task = []
          if Hunter::TASKS.empty?
            Thread.pass
            sleep(3)
            next
          end

          Hunter::TASKS.each do |task|
            next unless task.terminal?

            if task.vulnerable?
              delete_task << task
              request_file = task.option_get('requestFile')
              puts Hunter.info("[+] Vulnerable: #{task.task_id} requestFile: #{request_file}")
            else
              delete_task << task
              puts Hunter.warning("[-] #{task.task_id}: all tested parameters appear to be not injectable")
            end
          end

          Hunter::MUTEX.synchronize {
            delete_task.each do |task|
              task.delete
              task.delete_file
              Hunter::TASKS.delete task
            end
          }
        end
      }

      @threads.each { |thr| thr.join }
    end
  end
end