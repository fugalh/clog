#!/usr/bin/ruby

module Clog
  class Filter
    attr_accessor :name, :glob
    def match(line)
      true
    end
    def syslog_parse(line)
      return false unless line =~ /(\S+\s+\S+\s+\d\d:\d\d:\d\d) (\S+) (\S+)(\[(\d+)\])?: (.*)/
      time,hostname,tag,pid,msg = $1,$2,$3,$5,$6
    end
    def filter(line)
    end
    def report
      ""
    end
  end
  class Fallback < Filter
    def initialize
      @name = "Fallback"
      @lines = []
    end
    def filter(line)
      @lines.push line
    end
    def report
      @lines.to_s
    end
  end
end

if $0 == __FILE__
  require 'optparse'
  require 'yaml'
  require 'ostruct'
  require 'zlib'
  require 'time'

  def parsedate(date)
    Time.parse(`date -d "#{date}"`)
  end
  # command-line options
  options = {
    :config_file => "/etc/clog/clog.conf",
    :from => parsedate('yesterday'),
    :to => parsedate("now")
  }
  opts = OptionParser.new do |opts|
    opts.banner = "usage: #{$0} [options]"
    
    opts.on('-c','--config PATH','specify configuration file') {
      |options[:config_file]|}
    opts.on('-C','--show-config','show real configuration') {
      |options[:show_config]|}
    opts.on('-f','--from DATE','start date (yesterday)') { |d|
      options[:from] = parsedate(d)
    }
    opts.on('-t','--to DATE','start date (now)') { |d|
      options[:to] = parsedate(d)
    }
    opts.on('-h','--help','this message') { puts opts; exit }
    opts.separator ''
    opts.separator('Dates are in the format that date(1) accepts')
  end
  opts.parse!(ARGV)
  starttime = Time.now

  # configuration file
  config = OpenStruct.new(YAML.load(File.read(options[:config_file])).merge(options))
  puts config.inspect if config.show_config

  # built-in filters
  fallback = Clog::Fallback.new

  # load filters
  Dir.glob("#{config.filter_dir}/*.rb") { |f|
    load f
  }
  filters = []
  files = []
  config.filters.each do |f|
    a = eval("Clog::#{f['class']}.new")
    a.name = f['name'] || f['class']
    a.glob = f['glob'] || ''
    files.concat Dir.glob(a.glob)
    filters.push a
  end
  files.uniq!

  # do it, rockapella
  files.sort.reverse.each do |file|
    next if File.mtime(file) < config.from
    unless File.readable?(file)
      $stderr.puts "warning: #{file} is not readable."
      next
    end
    if system("file \"#{file}\"|grep -q \"gzip compressed data\"")
      io = Zlib::GzipReader.open(file)
    else
      io = File.open(file)
    end
    t_filters = filters.find_all { |f| File.fnmatch(f.glob,file) }
    io.each_line do |line|
      t = Time.parse(line[0,15],config.to)
      next if t < config.from or t > config.to
      matching_filters = t_filters.find_all {|f| f.match(line)}
      matching_filters.each do |f|
	f.filter(line)
      end
      fallback.filter(line) if config.fallback and matching_filters.empty?
    end
    io.close
  end

  # output
  puts <<EOF

********************************* clog *********************************
From: #{config.from.rfc2822} 
  To: #{config.to.rfc2822}

Processing time: #{Time.now - starttime} seconds
************************************************************************
EOF
  (filters + [fallback]).each do |f|
    name = "(nameless)"
    name = f.name if f.respond_to? "name"
    puts "\n---- #{name} ----"
    puts f.report
  end
end
