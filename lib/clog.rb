# :include:README

class Hash
  # Make a hash out of an array of keys and an array of values. Obviously, they
  # should be arrays of the same arity.
  def Hash.fold(keys,values)
    Hash[*keys.zip(values).flatten]
  end
end

module Clog
  # This abstract class is the basis for all agents.
  class Agent
    # This method is called for every line in the log file(s).
    # If this line has already been handled by another agent, handled will be
    # true. This is just informative, you can still do whatever you want with
    # the line. If another agent already consumed this line, then this
    # will never be called.
    #
    # Returns one of {:unhandled, :handled, :consumed}
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
  # Returns a hash with keys {:time, :hostname, :tag, :pid, :msg}, or false on
  # failure.
  def syslog_parse(line)
    return false unless line =~ /(\S+\s+\S+\s+\d\d:\d\d:\d\d) (\S+) (\S+)(\[(\d+)\])?: (.*)/
    keys = [:time,:hostname,:tag,:pid,:msg]
    values = [$1,$2,$3,$5,$6]
    Hash.fold(keys,values)
  end

  # Return a Time object given a string representation that date(1) understands
  def parsedate(date)
    Time.parse(`date -d "#{date}"`)
  end

  # Directs the feeding and reporting of agents for a given file glob.
  class Director
    def initialize(glob, agents, ignore, from, to)
      @glob, @agents, @from, @to = glob, agents, from, to
      ignore ||= []
      r = ignore.collect{|i| 
	i = i[1..-2] if i =~ %r{^/.*/$}
	Regexp.new(i)
      }
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
	io = Zlib::GzipReader.open(f) rescue io = File.open(f)
	io.each_line do |l|
	  # skip if ignored
	  next if @ignore and @ignore.match(l) 

	  # skip if out of date range
	  t = Time.parse(l[0,15],@to)
	  next if t < @from or t > @to

	  handled = :unhandled
	  @agents.each do |a|
	    break if handled == :consumed
	    handled = a.handle(l,handled) rescue nil
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
