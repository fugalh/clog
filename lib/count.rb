module Clog
  # simple example filter that just does the equivalent of 'wc -l'
  class CountFilter < Filter
    def initialize
      @count = 0
      @name = 'Count'
    end
    def match(line)
      line =~ /./
    end
    # will only be called on lines that pass match()
    def filter(line)
      @count += 1
    end
    # this is the output of the filter, called after all lines have been fed to
    # filter()
    def report
      "line count: #{@count.to_s}"
    end
  end
end
