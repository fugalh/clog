module Clog
  class Dhclient < Agent
    def initialize
      @leases = []
    end
    def handle(line,handled)
      return false, false unless line =~ / dhclient:/
      p = syslog_parse(line)
      @server = $1 if p.last =~ /DHCPACK from (.*)/
      if p.last =~ /bound to (\d+\.\d+\.\d+\.\d+)/
	@leases.push sprintf("%s  %s\tfrom %s", p[0], $1, @server)
      end
      return true,true
    end
    def report
      @leases.join "\n"
    end
  end
end
