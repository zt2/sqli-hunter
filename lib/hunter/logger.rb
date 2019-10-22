# frozen_string_literal: true

#
# Third party libraries
#
require 'formatador'

module Hunter
  #
  # Logger module
  #
  module Logger
    class << self
      # Display error message
      #
      # @param msg [String] Message
      def error(msg)
        Formatador.display_line("[red][#{Time.now.strftime('%T')}] [ERROR] #{msg}[/]")
      end

      # Display warning message
      #
      # @param msg [String] Message
      def warn(msg)
        Formatador.display_line("[yellow][#{Time.now.strftime('%T')}] [WARN] #{msg}[/]")
      end

      # Display info message
      #
      # @param msg [String] Message
      def info(msg)
        Formatador.display_line("[blue][#{Time.now.strftime('%T')}] [INFO] #{msg}[/]")
      end

      # Display debug message
      #
      # @param msg [String] Message
      def debug(msg)
        Formatador.display_line("[white][#{Time.now.strftime('%T')}] [DEBUG] #{msg}[/]")
      end

      # Display succ message
      #
      # @param msg [String] Message
      def succ(msg)
        Formatador.display_line("[green][#{Time.now.strftime('%T')}] [SUCCESS] #{msg}[/]")
      end
    end
  end
end
