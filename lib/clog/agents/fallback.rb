require 'clog'

module Clog
  # This is the fallback class that simply regurgitates the lines fed to it.
  class Fallback < Agent
    def initialize
      @lines = []
    end
    def handle(line, handled)
      return :unhandled unless handled == :unhandled
      @lines.push line
      return :consumed
    end
    def report
      @lines.join ""
    end
  end
end
