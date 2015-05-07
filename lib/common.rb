module Hunter
  class Common
    @@version = '1.0'
    @@request_queue = Queue.new
    @@task_queue = []
    @@mutex = Mutex.new
    @@verbose = 1

    def initialize
    end

    def set_verbose(verbose)
      @verbose = verbose
    end

    # Define colors
    def colorize(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end

    def bold(text)
      colorize(text, 1)
    end

    def red(text)
      colorize(text, 31)
    end

    def green(text)
      colorize(text, 32)
    end

    def amber(text)
      colorize(text, 33)
    end

    def blue(text)
      colorize(text, 34)
    end

    def critical(text)
      red(text)
    end

    def warning(text)
      amber(text)
    end

    def info(text)
      green(text)
    end

    def notice(text)
      blue(text)
    end

    def print_msg(msg, type, level)
      instance_eval("puts #{type}('#{msg}')") if @@verbose >= level
    end
  end
end
