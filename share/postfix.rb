module Clog
  class Postfix < Agent
    def handle(line,handled)
      case line
      when / postfix\//
	h = syslog_parse(line)
	return :unhandled unless h 
      else
	:unhandled
      end
    end
    def report
      ""
    end
  end
end
