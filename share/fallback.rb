module Clog
  # This is the fallback class that simply regurgitates the lines fed to it.
  class Fallback < Agent
    def initialize
      @lines = []
    end
    def handle(line, handled)
      @lines.push line
      return true,true
    end
    def report
      @lines.join ""
    end
  end
end
