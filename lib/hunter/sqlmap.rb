# frozen_string_literal: true

#
# Standard libraries
#
require 'tmpdir'
require 'securerandom'

#
# Third party libraries
#
require 'formatador'

#
# Custom libraries
#
require_relative 'logger'

module Hunter
  #
  # SQLMAP API client
  #
  module SQLMAP
    require_relative 'sqlmap/task'

    class << self
      attr_accessor :api_host, :api_port, :options

      # Configuration for SQLMAP
      #
      def config
        @save_dir = Dir.mktmpdir
        yield self if block_given?
      end

      # Scan
      #
      # @param [WEBrick::HTTPRequest] req
      def run(req)
        request_file = _save_request_file(req)

        task = _create_task(request_file)

        task.start
        Hunter::Logger.info("[#{task.id}] Task started")

        sleep(2) until task.stopped?
        Hunter::Logger.info("[#{task.id}] Task finished")

        if task.vulnerable?
          Hunter::Logger.succ("[#{task.id}] Task vulnerable, use 'sqlmap -r #{request_file}' to exploit")
        else
          Hunter::Logger.warn("[#{task.id}] All tested parameters appear to be not injectable")
        end
      ensure
        task.destroy
      end

      private

      def _save_request_file(req)
        request_file = File.join(@save_dir, SecureRandom.hex(16))
        File.write(request_file, req.to_s)
        request_file
      end

      def _create_task(request_file)
        task = Hunter::SQLMAP::Task.new(api_host, api_port)
        Hunter::Logger.info("[#{task.id}] Task created")

        task.set(requestFile: request_file)
        task.set(options)

        task
      end
    end
  end
end
