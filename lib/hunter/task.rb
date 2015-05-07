module Hunter
  class Task < Hunter::Common
    attr_reader :task_id

    def initialize(host, save_path)
      @host = host
      @save_path = save_path
      @headers = {
        'Content-Type' => 'application/json'
      }

      path = '/task/new'
      res = Typhoeus.get(@host + path)
      @task_id = nil if res.timed_out?

      result = JSON.load(res.body)
      @task_id = result['success'] ? result['taskid'] : nil
    end

    def delete
      path = "/task/#{@task_id}/delete"
      res = Typhoeus.get(@host + path)

      result = JSON.load(res.body)
      result['success'] ? true : false
      @task_id = nil
    end

    def option_list
      path = "/option/#{@task_id}/list"
      res = Typhoeus.get(@host + path)

      result = JSON.load(res.body)
      result['success'] ? result['options'] : false
    end

    def option_get(option)
      path = "/option/#{@task_id}/get"
      options = {
        option: option
      }
      res = Typhoeus.post(@host + path, headers: @headers, body: JSON.dump(options))

      result = JSON.load(res.body)
      result['success'] ? result[option] : false
    end

    def option_set(options)
      path = "/option/#{@task_id}/set"

      res = Typhoeus.post(@host + path, headers: @headers, body: JSON.dump(options))

      result = JSON.load(res.body)
      result['success'] ? true : false
    end

    def scan_start
      path = "/scan/#{@task_id}/start"
      body = {}
      res = Typhoeus.post(@host + path, headers: @headers, body: JSON.dump(body))

      result = JSON.load(res.body)
      result['success'] ? true : false
    end

    def scan_stop
      path = "/scan/#{@task_id}/stop"
      res = Typhoeus.get(@host + path)

      result = JSON.load(res.body)
      result['success'] ? true : false
    end

    def scan_kill
      path = "/scan/#{@task_id}/kill"
      res = Typhoeus.get(@host + path)

      result = JSON.load(res.body)
      result['success'] ? true : false
    end

    def scan_status
      path = "/scan/#{@task_id}/status"
      res = Typhoeus.get(@host + path)

      result = JSON.load(res.body)
      result['success'] ? result['status'] : false
    end

    def scan_data
      path = "/scan/#{@task_id}/data"
      res = Typhoeus.get(@host + path)

      result = JSON.load(res.body)
      result['success'] ? result['data'] : false
    end

    def terminal?
      scan_status.eql? 'terminated'
    end

    def vulnerable?
      scan_data.empty? ? false : true
    end

    def delete_file
      File.delete @save_path unless vulnerable?
    end
  end
end
