module Clog
  class Postfix < Agent
    def handle(line,handled)
      line =~ / postfix\// ? :consumed : :unhandled
    end
    def report
      ""
    end
  end
end
