module Clog
  class Dhclient < Filter
    def initialize
      @leases = []
    end
    def match(line)
      line =~ / dhclient:/
    end
    def filter(line)
      p = syslog_parse(line)
      @server = $1 if p.last =~ /DHCPACK from (.*)/
      if p.last =~ /bound to (\d+\.\d+\.\d+\.\d+)/
	@leases.push sprintf("%s: %s\tfrom %s", p[0], $1, @server)
      end
    end
    def report
      @leases.join "\n"
    end
  end
end
