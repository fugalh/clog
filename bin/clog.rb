#!/usr/bin/ruby

# command-line options
require 'optparse'
options = {
  :config_file => "/etc/clog/clog.conf",
  :fallback => true
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
require 'yaml'
require 'ostruct'
config = OpenStruct.new(YAML.load(File.read(options[:config_file])).merge(options))
puts config.inspect if config.show_config

# built-in filters
module Clog
  class Filter
    attr_accessor :name, :glob
  end

  class FallbackFilter < Filter
    def initialize
      @lines = []
      @name = "Fallback"
    end
    def filter(line)
      @lines ||= []
      @lines.push line
      true
    end
    def to_s
      @lines
    end
  end
end
fallback = Clog::FallbackFilter.new

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

# do it, rockapella
files.each do |file|
  File.read(file).each_line do |line|
    handled = false
    filters.each do |f|
      if File.fnmatch("#{f.glob}",file)
	handled |= f.filter(line)
      end
    end
    fallback.filter(line) unless handled or not config.fallback
  end
end
(filters.concat [fallback]).each do |f|
  name = "(nameless)"
  name = f.name if f.respond_to? "name"
  puts "\n---- #{name} ----"
  puts f.to_s
end
