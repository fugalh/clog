module Clog
  class Postfix < Filter
    def match(line)
      line =~ / postfix\//
    end
    def filter(line)
    end
    def to_s
    end
  end
end
