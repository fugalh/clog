#!/usr/bin/ruby

# :include:README
module Clog
  # This abstract class is the basis for all agents.
  # Included agents:
  #
  # :include:agents
  class Agent
    # This method is called for every line in the log file(s).
    # If this line has already been handled by another agent, handled will be
    # true. This is just informative, you can still do whatever you want with
    # the line. If another agent already consumed this line, then this
    # will never be called.
    #
    # Returns one of {:unhandled,:handled,:consumed}
    def handle(line, handled)
      return :unhandled
    end

    # This method is called after all lines have been fed to handle(). 
    #
    # Returns a string suitable for the body of an email (e.g. wrapped at 72
    # characters wherever possible, etc.)
    def report
      ""
    end

  end

  # This is a convenience method for handling syslog entries. 
  # 
  # Returns time,hostname,tag,pid,msg
  def syslog_parse(line)
    return false unless line =~ /(\S+\s+\S+\s+\d\d:\d\d:\d\d) (\S+) (\S+)(\[(\
d+)\])?: (.*)/
    time,hostname,tag,pid,msg = $1,$2,$3,$5,$6
  end

  def parsedate(date)
    Time.parse(`date -d "#{date}"`)
  end

  # Directs the feeding and reporting of agents for a given file glob.
  class Director
    def initialize(glob, agents, ignore, from, to)
      @glob, @agents, @from, @to = glob, agents, from, to
      ignore ||= []
      r = ignore.collect{|i| Regexp.new(i)}
      @ignore = Regexp.union(*r)
    end
    def run
      files = Dir.glob(@glob)
      files.sort! { |a,b| File.mtime(a) <=> File.mtime(b) }
      files.reverse!
      files.each do |f|
	next if File.mtime(f) < @from
	unless File.readable?(f)
	  $stderr.puts "warning: #{f} is not readable."
	  next
	end
	if system("file \"#{f}\"|grep -q 'gzip compressed data'")
	  io = Zlib::GzipReader.open(f)
	else
	  io = File.open(f)
	end
	io.each_line do |l|
	  # skip if ignored
	  next if @ignore and @ignore.match(l) 

	  # skip if out of date range
	  t = Time.parse(l[0,15],@to)
	  next if t < @from or t > @to

	  handled = :unhandled
	  @agents.each do |a|
	    break if handled == :consumed
	    handled = a.handle(l,handled)
	  end
	end
	io.close
      end
    end
    def report
      <<EOF
----- #{@glob} -----

#{@agents.collect {|a| <<EOF2
-= #{a.class.to_s['Clog::'.size .. -1]} =-
#{a.report}

EOF2
}.join ""}
EOF
    end
  end
end

if $0 == __FILE__
  require 'optparse'
  require 'yaml'
  require 'ostruct'
  require 'zlib'
  require 'time'

  include Clog
  # command-line options
  options = OpenStruct.new({
    :config_file => "/etc/clog/clog.conf",
    :from => parsedate("yesterday"),
    :to => parsedate("now")
  })
  opts = OptionParser.new do |opts|
    opts.banner = "usage: #{$0} [options]"
    
    opts.on('-c','--config PATH','specify configuration file') {
      |options.config_file|}
    opts.on('-C','--show-config','show real configuration') {
      |options.show_config|}
    opts.on('-f','--from DATE','start date (yesterday)') { |d|
      options.from = parsedate(d)
    }
    opts.on('-t','--to DATE','start date (now)') { |d|
      options.to = parsedate(d)
    }
    opts.on('-h','--help','this message') { puts opts; exit }
    opts.separator ''
    opts.separator('Dates are in the format that date(1) accepts')
  end
  opts.parse!(ARGV)
  starttime = Time.now

  # configuration file
  config = OpenStruct.new(YAML.load(File.read(options.config_file)))
  puts config.inspect if options.show_config

  # load agents
  Dir.glob("#{config.agent_dir}/*.rb") { |f|
    load f
  }
  directors = []
  config.files.each do |f|
    glob = f['glob']
    agents = []
    f['agents'].each do |a|
      agents.push eval("Clog::#{a}.new")
    end
    ignore = f['ignore']
    directors.push Director.new(glob,agents,ignore,options.from,options.to)
  end

  # run
  directors.each {|d| d.run}

  # output
  puts <<EOF

********************************* clog *********************************
From: #{options.from.rfc2822} 
  To: #{options.to.rfc2822}

Processing time: #{Time.now - starttime} seconds
************************************************************************

EOF

  directors.each do |d| 
    puts d.report 
  end
end
