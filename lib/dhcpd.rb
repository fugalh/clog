module Clog
  class Dhcpd < Filter
    def initialize
      @leases = []
    end
    def match(line)
      line =~ / dhcpd:/
    end
    def filter(line)
      p = syslog_parse(line)
      if p.last =~ /DHCPACK on ([\d.]+) to ([\dabcdef:]+) (\((\S+)\) )?via (\S+)/
	hostname = $4 ? "[#{$4}] " : ""
	@leases.push sprintf("%s => %s %s(%s)", $2, $1, hostname, $5)
      end
    end
    def report
      @leases.uniq.collect {|l| "#{@leases.find_all{|a| a == l}.size.to_s}x  #{l}" }.join "\n"
    end
  end
end
