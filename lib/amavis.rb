module Clog
  class Amavis < Filter
    def initialize
      @passed   = 0
      @infected = 0
    end
    def match(line)
      line =~ / amavis\[/
    end
    def filter(line)
      @infected += 1 if line =~ /INFECTED/
      @passed   += 1 if line =~ /Passed/
    end
    def report
      sprintf "%3d passed\n%3d infected", @passed, @infected
    end
  end
end
