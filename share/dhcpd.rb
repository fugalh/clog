module Clog
  class Dhcpd < Agent
    def initialize
      @leases = []
    end
    def handle(line,handled)
      return :unhandled unless line =~ / dhcpd:/
      p = syslog_parse(line)
      if p.last =~ /DHCPACK on ([\d.]+) to ([\dabcdef:]+) (\((\S+)\) )?via (\S+)/
	hostname = $4 ? "[#{$4}] " : ""
	@leases.push sprintf("%s => %s %s(%s)", $2, $1, hostname, $5)
      end
      return :consumed
    end
    def report
      @leases.uniq.collect {|l| "#{@leases.find_all{|a| a == l}.size.to_s}x  #{l}" }.join "\n"
    end
  end
end
