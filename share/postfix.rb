module Clog
  class Postfix < Agent
    def initialize
      @rejected = 0
      @connections = 0
      @lost_connections = 0
      @accepted = 0
      @locals = 0
      @sent = @deferred = @bounced = 0
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
	  @rejected += 1
	  :consumed
	when /^connect /
	  @connections += 1
	  :consumed
	when /^lost connection/
	  @lost_connections += 1
	  :consumed
	when /^[0-9A-F]{10,10}:/
	  @accepted += 1
	  :consumed
	when /^disconnect /,/verification failed/,/^too many errors/,
	  /address not listed/,/^timeout/,/sent non-SMTP command/
	  :consumed
	end
      when %r{postfix/smtp}
	case h[:msg]
	when /^[0-9A-F]{10,10}:.*status=sent/
	  @sent += 1
	  :consumed
	when /^[0-9A-F]{10,10}:.*status=deferred/
	  @deferred += 1
	  :consumed
	when /^[0-9A-F]{10,10}:.*status=bounced/
	  @bounced += 1
	  :consumed
	when /^connect to/,/numeric domain name/
	  :consumed
	end
      when %r{postfix/local}
	case h[:msg]
	when /^[0-9A-F]{10,10}:/
	  @locals += 1
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
  #{@connections} connections.
  #{@rejected} connections rejected.
  #{@lost_connections} connections lost.
  #{@accepted} messages accepted.

local:
  #{@locals} local messages.

smtp:
  #{@sent} sent.
  #{@deferred} deferred.
  #{@bounced} bounced.

Unrecognized:
  #{@unrecognized.join "\n  "}
EOF
    end
  end
end
