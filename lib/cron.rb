module Clog
  class Cron < Filter
    def initialize
      @entries = []
      @replaces = []
    end
    def match(line)
      line =~ /\/cron|anacron|crontab/i
    end
    def filter(line)
      p = syslog_parse(line)
      if p.last =~ /\((\S+)\) CMD \((.*)\)/
	@entries.push({'username'=>$1,'cmd'=>$2})
      elsif p.last =~ /\((\S+)\) REPLACE \((\S+)\)/
	@replaces.push(line)
      end
    end
    def report
      count = {}
      s = ""

      @replaces.each {|r| s += r}

      @entries.each do |e| 
	count[e['cmd']] ||= 0
	count[e['cmd']] += 1
      end
      count.each {|k,v| s += sprintf("%2d times: %s\n",v,k)}

      s
    end
  end
end
