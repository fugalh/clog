module Clog
  # This is the fallback class that simply regurgitates the lines fed to it.
  class Fallback < Agent
    def initialize
      @lines = []
    end
    def handle(line, handled)
      return false,false if handled
      @lines.push line
      return false,true
    end
    def report
      @lines.join ""
    end
  end
end
