require 'clog'

module Clog
  class Postfix < Agent
    def initialize
      @smtp = Hash.new(0)
      @smtpd = Hash.new(0)
      @virtual = Hash.new(0)
      @local = Hash.new(0)
      @pickup = Hash.new(0)
      @qmgr = Hash.new(0)
      @unrecognized = []
    end
    def handle(line,handled)
      h = syslog_parse(line) or return :unhandled
      h[:tag] =~ /postfix/ or return :unhandled
      case h[:tag]
      when %r{postfix/qmgr}
	:consumed
      when %r{postfix/smtpd}
	case h[:msg]
	when /^NOQUEUE: reject/
	  @smtpd[:rejected] += 1
	  :consumed
	when /^connect /
	  @smtpd[:connections] += 1
	  :consumed
	when /^lost connection/
	  @smtpd[:lost_connections] += 1
	  :consumed
	when /^[0-9A-F]{10,10}:/
	  @smtpd[:accepted] += 1
	  :consumed
	when /^disconnect /,/verification failed/,/^too many errors/,
	  /address not listed/,/^timeout/,/sent non-SMTP command/
	  :consumed
	end
      when %r{postfix/pickup}
	case h[:msg]
	when /^[0-9A-F]{10,10}:/
	  @pickup[:messages] += 1
	  :consumed
	end
      when %r{postfix/virtual}
	case h[:msg]
	when /^[0-9A-F]{10,10}:.*status=sent/
	  @virtual[:sent] += 1
	  :consumed
	end
      when %r{postfix/smtp}
	case h[:msg]
	when /^[0-9A-F]{10,10}:.*status=sent/
	  @smtp[:sent] += 1
	  :consumed
	when /^[0-9A-F]{10,10}:.*status=deferred/
	  @smtp[:deferred] += 1
	  :consumed
	when /^[0-9A-F]{10,10}:.*status=bounced/
	  @smtp[:bounced] += 1
	  :consumed
	when /^connect to/,/numeric domain name/
	  :consumed
	end
      when %r{postfix/local}
	case h[:msg]
	when /^[0-9A-F]{10,10}:/
	  @local[:locals] += 1
	  :consumed
	end
      when %r{postfix/cleanup}
	:consumed
      end or begin
        @unrecognized.push "#{h[:tag]}: #{h[:msg]}"
	:consumed
      end
    end
    def report
      <<EOF
smtpd:
  #{@smtpd[:connections]} connections.
  #{@smtpd[:rejected]} connections rejected.
  #{@smtpd[:lost_connections]} connections lost.
  #{@smtpd[:accepted]} messages accepted.

smtp:
  #{@smtp[:sent]} sent.
  #{@smtp[:deferred]} deferred.
  #{@smtp[:bounced]} bounced.

local:
  #{@local[:locals]} messages.

pickup:
  #{@pickup[:messages]} messages.

Unrecognized:
  #{@unrecognized.join "\n  "}
EOF
    end
  end
end
