module Clog
  class Amavis < Agent
    def initialize
      @passed   = 0
      @infected = 0
    end
    def handle(line,handled)
      return false,false unless line =~ / amavis\[/
      @infected += 1 if line =~ /INFECTED/
      @passed   += 1 if line =~ /Passed/
      return true,true
    end
    def report
      sprintf "%3d passed\n%3d infected", @passed, @infected
    end
  end
end
