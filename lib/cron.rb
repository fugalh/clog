module Clog
  class Cron < Filter
    def initialize
      @commands = {}
    end
    def match(line)
      line =~ /CRON/
    end
    def filter(line)
      p = syslog_parse(line)
      if p.last =~ /\((\S+)\) CMD \((.*)\)/
	user = $1
	@commands[user] ||= []
	@commands[user].push $2.strip
      end
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
