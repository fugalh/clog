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
  class Anacron < Agent
    def initialize
      @commands = {}
      @jobs = 0
    end
    def handle(line,handled)
      return false,false unless line =~ /anacron\[/
      p = syslog_parse(line)
      @jobs += 1 if p.last =~ /(\d+) jobs? run/
      return true,true
    end
    def report
      s = ""
      case @jobs
      when 0
	s = "No jobs run."
      when 1
	s = "1 job run."
      when Integer
	s = "#{@jobs} jobs run."
      end
      s
    end
  end
end
