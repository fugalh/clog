module Clog
  class Cron < Agent
    def initialize
      @commands = {}
    end
    def handle(line,handled)
      return false,false unless line =~ /CRON/
      p = syslog_parse(line)
      if p.last =~ /\((\S+)\) CMD \((.*)\)/
	user = $1
	@commands[user] ||= []
	@commands[user].push $2.strip
      end
      return true,true
    end
    def report
      s = ""
      @commands.each do |k,v|
	s << "#{k}:\n"
	count = {}

	v.each do |e| 
	  count[e] ||= 0
	  count[e]  += 1
	end
	count.each {|k,v| s << sprintf(" %3dx  %s\n",v,k)}
      end

      s
    end
  end
end
