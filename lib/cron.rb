module Clog
  class Cron < Filter
    def initialize
      @name = "cron"
      @entries = []
    end
    def filter(line)
      return false unless p = syslog_parse(line)
      return false unless p[2] =~ /CRON/
      return false unless p.last =~ /\((\S+)\) CMD \((.*)\)/
      @entries.push({'username'=>$1,'cmd'=>$2})
      true
    end
    def to_s
      count = {}
      s = ""

      @entries.each do |e| 
	count[e['cmd']] ||= 0
	count[e['cmd']] += 1
      end

      count.each {|k,v| s += sprintf("%2d times: %s\n",v,k)}
      s
    end
  end
end

#Dec  9 18:17:01 localhost /USR/SBIN/CRON[9193]: (root) CMD (   run-parts --report /etc/cron.hourly)
#Dec  9 18:39:01 localhost /USR/SBIN/CRON[9601]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec  9 19:09:01 localhost /USR/SBIN/CRON[9979]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec  9 19:17:02 localhost /USR/SBIN/CRON[10083]: (root) CMD (   run-parts --report /etc/cron.hourly)
#Dec  9 19:39:02 localhost /USR/SBIN/CRON[10351]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec  9 20:09:01 localhost /USR/SBIN/CRON[10720]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec  9 20:17:02 localhost /USR/SBIN/CRON[10831]: (root) CMD (   run-parts --report /etc/cron.hourly)
#Dec  9 20:39:02 localhost /USR/SBIN/CRON[11099]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec  9 21:09:01 localhost /USR/SBIN/CRON[11469]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec  9 21:17:02 localhost /USR/SBIN/CRON[11573]: (root) CMD (   run-parts --report /etc/cron.hourly)
#Dec  9 21:39:02 localhost /USR/SBIN/CRON[11848]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec  9 22:09:01 localhost /USR/SBIN/CRON[12228]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec  9 22:17:02 localhost /USR/SBIN/CRON[12333]: (root) CMD (   run-parts --report /etc/cron.hourly)
#Dec  9 22:39:02 localhost /USR/SBIN/CRON[12607]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec 10 08:17:01 localhost /USR/SBIN/CRON[13595]: (root) CMD (   run-parts --report /etc/cron.hourly)
#Dec 10 08:39:02 localhost /USR/SBIN/CRON[13984]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec 10 09:09:01 localhost /USR/SBIN/CRON[14664]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec 10 09:17:01 localhost /USR/SBIN/CRON[14828]: (root) CMD (   run-parts --report /etc/cron.hourly)
#Dec 10 09:39:01 localhost /USR/SBIN/CRON[15342]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec 10 10:09:01 localhost /USR/SBIN/CRON[15720]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec 10 10:17:01 localhost /USR/SBIN/CRON[15851]: (root) CMD (   run-parts --report /etc/cron.hourly)
#Dec 10 10:39:01 localhost /USR/SBIN/CRON[16248]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec 10 11:09:01 localhost /USR/SBIN/CRON[16763]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
#Dec 10 11:17:01 localhost /USR/SBIN/CRON[16925]: (root) CMD (   run-parts --report /etc/cron.hourly)
#Dec 10 11:39:02 localhost /USR/SBIN/CRON[17379]: (root) CMD (  [ -d /var/lib/php4 ] && find /var/lib/php4/ -type f -cmin +$(/usr/lib/php4/maxlifetime) -print0 | xargs -r -0 rm)
