module Clog
  # simple example filter that just does the equivalent of 'wc -l'
  class CountFilter < Filter
    def initialize
      @count = 0
      @name = 'Count'
    end
    # return value: true if we "handled" this line, else false
    def filter(line)
      @count += 1
    end
    # this is the output of the filter, called when all lines have been fed to
    # filter()
    def report
      "line count: #{@count.to_s}"
    end
  end
end
