module Clog
  class Postfix < Agent
    def handle(line,handled)
      return false,false unless line =~ / postfix\//
      return true,true
    end
    def report
      ""
    end
  end
end
