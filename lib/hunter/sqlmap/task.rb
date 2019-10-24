# frozen_string_literal: true

#
# Third party libraries
#
require 'http'

#
# Custom libraries
#
require_relative '../logger'

module Hunter
  module SQLMAP
    #
    # Task for scanning
    #
    class Task
      #
      # Errors
      #

      # Base error
      class Error < RuntimeError; end

      # Task errors
      class TaskError < Error; end
      class TaskCreateError < TaskError; end
      class TaskDestroyError < TaskError; end
      class TaskStartError < TaskError; end
      class TaskStopError < TaskError; end
      class TaskKillError < TaskError; end
      class TaskStatusRetrieveError < TaskError; end
      class TaskDataRetrieveError < TaskError; end
      class TaskOptionSetError < TaskError; end
      class TaskOptionGetError < TaskError; end

      # HTTP errors
      class HTTPError < Error; end
      class HTTPCodeError < HTTPError; end

      attr_reader :id

      # Class constructor
      #
      # @param host [String] Host for SQLMAP API
      # @param port [Integer] Port for SQLMAP API
      def initialize(host, port)
        @url = "http://#{host}:#{port}"
        @id = _create_task(@url)
      end

      # Destroy task
      #
      def destroy
        url = "#{@url}/task/#{@id}/delete"
        result = _send_request(:get, url)
        raise(TaskDestroyError, result['message']) unless result['success']
      end

      # Set options
      #
      # @param options [Hash] Options
      def set(options)
        url = "#{@url}/option/#{@id}/set"
        result = _send_request(:post, url, body: options)
        raise(TaskOptionSetError, result['message']) unless result['success']
      end

      # Get options
      #
      # @param options [Array<String>] An array of options
      # @return [Hash]
      def get(options)
        url = "#{@url}/option/#{@id}/get"
        result = _send_request(:post, url, body: options)
        raise(TaskOptionGetError, result['message']) unless result['success']

        result['options']
      end

      # Start the task
      #
      def start
        url = "#{@url}/scan/#{@id}/start"
        # We already set options
        result = _send_request(:post, url, body: {})
        raise(TaskStartError, result['message']) unless result['success']
      end

      # Stop the task
      #
      def stop
        url = "#{@url}/scan/#{@id}/stop"
        # We already set options
        result = _send_request(:get, url)
        raise(TaskStartError, result['message']) unless result['success']
      end

      # Kill the task
      #
      def kill
        url = "#{@url}/scan/#{@id}/kill"
        # We already set options
        result = _send_request(:get, url)
        raise(TaskKillError, result['message']) unless result['success']
      end

      # Retrieve status
      #
      def status
        url = "#{@url}/scan/#{@id}/status"
        # We already set options
        result = _send_request(:get, url)
        raise(TaskStatusRetrieveError, result['message']) unless result['success']

        result['status']
      end

      # Return true if task is stopped
      #
      # @return [Boolean]
      def stopped?
        status == 'terminated'
      end

      # Return true if task is running
      #
      # @return [Boolean]
      def running?
        status == 'running'
      end

      # Return true if task is vulnerable
      #
      # @return [Boolean]
      def vulnerable?
        url = "#{@url}/scan/#{@id}/data"
        result = _send_request(:get, url)
        raise(TaskDataRetrieveError, result['message']) unless result['success']

        !result['data'].empty?
      end

      private

      def _create_task(url)
        result = _send_request(:get, "#{url}/task/new")
        raise TaskCreateError unless result['success']

        result['taskid']
      end

      def _send_request(method, url, body: nil)
        res = if body.nil?
                HTTP.send(method, url)
              else
                HTTP.send(method, url, json: body)
              end

        if res.code != 200
          message = "invalid http code: #{res.code}"
          raise(HTTPCodeError, message)
        end

        res.parse
      rescue HTTP::ConnectionError, HTTP::TimeoutError
        Hunter::Logger.warn('SQLMAP is busy for now, waiting')
        sleep(10)
        retry
      end
    end
  end
end
