module Hunter
  class Helper < Hunter::Common
    def initialize
      super
      @threads = []

      # Common options
      @common_options = OpenStruct.new
      @common_options.proxy_port = 8888
      @common_options.api_host = 'localhost:8775'
      @common_options.verbose = 1
      @common_options.save_path = '/tmp'

      # SQLmap options
      @sqlmap_options = OpenStruct.new
      @sqlmap_options.threads = 5
      @sqlmap_options.smart = false
      @sqlmap_options.tech = 'BEUSTQ'

      @banner = <<EOT

 _____ _____ __    _     _____         _
|   __|     |  |  |_|___|  |  |_ _ ___| |_ ___ ___
|__   |  |  |  |__| |___|     | | |   |  _| -_|  _|
|_____|__  _|_____|_|   |__|__|___|_|_|_| |___|_|
         |__|

      sqlmap api wrapper by ztz (ztz@ztz.me)

EOT
      usage = "Usage: #{$PROGRAM_NAME} [options]"
      OptionParser.new do |opts|
        opts.banner = @banner + usage

        opts.separator ''
        opts.separator 'Common options:'
        opts.on('-p <PORT>', '--port=<PORT>', OptionParser::DecimalInteger, 'Port of the Proxy-Server (default is 8888)') do |port|
          @common_options.proxy_port = port
        end

        opts.on('--api-host=<HOST>', String, 'Host of the sqlmapapi (default is localhost:8775)') do |host|
          @common_options.api_host = host
        end

        opts.on('-s <SAVE PATH>', '--save=<SAVE PATH>', String, 'Specify the path for request files (default is /tmp)') do |save_path|
          @common_options.save_path = save_path
        end

        opts.on('-v <VERBOSE>', 'Verbosity level: 0-3 (default 1)', OptionParser::DecimalInteger) do |verbose|
          @common_options.verbose = verbose
        end

        opts.on('--version', 'Show version') do
          puts "SQLi-Hunter version: '#{@@version}'"
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

      trap 'INT' do
        @@task_queue.each(&:delete_file)
        @threads.each(&:kill)
      end

      trap 'TERM' do
        @@task_queue.each(&:delete_file)
        @threads.each(&:kill)
      end

      @@verbose = @common_options.verbose
    end

    def start
      puts @banner

      @threads << Thread.new do
        captor = Hunter::Captor.new(port: @common_options.proxy_port, save_path: @common_options.save_path)
        captor.start
      end

      @threads << Thread.new do
        loop do
          if @@request_queue.empty?
            Thread.pass
            sleep(3)
            next
          end

          # Recv a request data (save path)
          save_path = @@request_queue.pop

          # Create a new task
          task = Hunter::Task.new(@common_options.api_host, save_path)

          unless task.task_id
            print_msg("[#{Time.now.strftime('%T')}] Create task error: #{save_path}, retry after 5s", :critical, 0)
            @@request_queue << save_path
            sleep(5)
            next
          end
          print_msg("[#{Time.now.strftime('%T')}] [#{task.task_id}] Create task", :notice, 1)

          # Set option
          @sqlmap_options.requestFile = save_path
          unless task.option_set(@sqlmap_options.to_h)
            print_msg("[#{Time.now.strftime('%T')}] Set options error: #{task.task_id}, retry after 5s", :critical, 0)
            @@request_queue << save_path
            task.delete
            sleep(5)
            next
          end
          print_msg("[#{Time.now.strftime('%T')}] [#{task.task_id}] Set options success", :notice, 1)

          # Run task
          unless task.scan_start
            print_msg("[#{Time.now.strftime('%T')}] Start scan error: #{task.task_id}, retry after 5s", :critical, 0)
            @@request_queue << save_path
            task.delete
            sleep(5)
            next
          end
          print_msg("[#{Time.now.strftime('%T')}] [#{task.task_id}] Task running", :notice, 1)

          @@mutex.synchronize do
            @@task_queue << task
          end
        end
      end

      @threads << Thread.new do
        loop do
          delete_task = []
          if @@task_queue.empty?
            Thread.pass
            sleep(3)
            next
          end

          @@task_queue.each do |task|
            print_msg("[#{Time.now.strftime('%T')}] [#{task.task_id}] Fetching result", :notice, 2)
            unless task.terminal?
              print_msg("[#{Time.now.strftime('%T')}] [#{task.task_id}] no result, waiting", :notice, 2)
              sleep(5)
              next
            end

            if task.vulnerable?
              delete_task << task
              request_file = task.option_get('requestFile')
              print_msg("[#{Time.now.strftime('%T')}] [#{task.task_id}] Task vulnerable, use \"sqlmap -r #{request_file}\" to exploit", :info, 0)
            else
              delete_task << task
              print_msg("[#{Time.now.strftime('%T')}] [#{task.task_id}] All tested parameters appear to be not injectable", :warning, 0)
            end
          end

          @@mutex.synchronize do
            delete_task.each do |task|
              task.delete_file
              task.delete
              @@task_queue.delete task
            end
          end
        end
      end

      @threads.each(&:join)
    end
  end
end
