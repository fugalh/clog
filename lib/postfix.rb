module Clog
  class Postfix < Filter
    def match(line)
      line =~ / postfix\//
    end
    def filter(line)
    end
    def report
      ""
    end
  end
end
