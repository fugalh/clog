#!/usr/bin/ruby

require 'optparse'
require 'yaml'
require 'ostruct'
require 'zlib'
# command-line options
options = {
  :config_file => "/etc/clog/clog.conf",
}
opts = OptionParser.new do |opts|
  opts.banner = "usage: #{$0} [options]"
  
  opts.on('-c','--config PATH','specify configuration file') {
    |options[:config_file]|}
  opts.on('-C','--show-config','show real configuration') {
    |options[:show_config]|}
  opts.on('-h','--help','this message') { puts opts; exit }
end
opts.parse!(ARGV)

# configuration file
config = OpenStruct.new(YAML.load(File.read(options[:config_file])).merge(options))
puts config.inspect if config.show_config

# built-in filters
module Clog
  class Filter
    attr_accessor :name, :glob
    def match(line)
      true
    end
    def syslog_parse(line)
      return false unless line =~ /(\S+\s+\d\d:\d\d:\d\d) (\S+) (\S+)(\[(\d+)\])?: (.*)/
      time,hostname,tag,pid,msg = $1,$2,$3,$5,$6
    end
  end
end

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
  files.concat Dir.glob("#{a.glob}")
  filters.push a
end
files.uniq!

# do it, rockapella
filters.each do |f|
  io = nil
  Dir.glob(f.glob).each do |file| 
    if system("file \"#{file}\"|grep -q \"gzip compressed data\"")
      io = Zlib::GzipReader.open(file,'r')
    else
      io = File.open(file,'r')
    end
  end
  io.each_line do |line|
    filters.each do |f|
      f.filter(line) if f.match(line)
    end
  end
  io.close
end
filters.each do |f|
  name = "(nameless)"
  name = f.name if f.respond_to? "name"
  puts "\n---- #{name} ----"
  puts f.to_s
end
