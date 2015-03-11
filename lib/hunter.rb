module Hunter
  extend self

  VERSION = '0.1'

  REQUESTS = Queue.new

  TASKS = []

  MUTEX = Mutex.new

  # Define colors
  def self.colorize(text, color_code)
    if $COLORSWITCH
      "#{text}"
    else
      "\e[#{color_code}m#{text}\e[0m"
    end
  end

  def self.bold(text)
    colorize(text, 1)
  end

  def self.red(text)
    colorize(text, 31)
  end

  def self.green(text)
    colorize(text, 32)
  end

  def self.amber(text)
    colorize(text, 33)
  end

  def self.blue(text)
    colorize(text, 34)
  end

  def self.critical(text)
    red(text)
  end

  def self.warning(text)
    amber(text)
  end

  def self.info(text)
    green(text)
  end

  def self.notice(text)
    blue(text)
  end
end