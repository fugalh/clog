module Clog
  # simple example agent that just does the equivalent of 'wc -l'
  class Count < Agent
    def initialize
      @count = 0
      @name = 'Count'
    end
    # will only be called on lines that pass match()
    def handle(line,handled)
      return :unhandled unless line =~ /./
      @count += 1
      return :consumed
    end
    # this is the output of the agent, called after all lines have been fed to
    # handle()
    def report
      "line count: #{@count.to_s}"
    end
  end
end
