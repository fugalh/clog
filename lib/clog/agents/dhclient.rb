require 'clog'

module Clog
  class Dhclient < Agent
    def initialize
      @leases = []
    end
    def handle(line,handled)
      h = syslog_parse(line) or return :unhandled
      h[:tag] =~ /dhclient/ or return :unhandled
      @server = $1 if h[:msg] =~ /DHCPACK from (.*)/
      if h[:msg] =~ /bound to (\d+\.\d+\.\d+\.\d+)/
	@leases.push sprintf("%s  %s\tfrom %s", p[0], $1, @server)
      end
      :consumed
    end
    def report
      @leases.join "\n"
    end
  end
end
