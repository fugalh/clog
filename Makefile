rdoc=rdoc1.8
test:
	echo "# this file is generated" > test/clog.conf
	sed "s:/usr/local/share/clog/agents:share:" etc/clog.conf >> test/clog.conf
	ruby bin/clog.rb -C -c test/clog.conf

doc:
	egrep "class .* < Agent" -r share/ | cut -d ' ' -f 4 | sed "s/^/- /" > agents
	${rdoc} -x _darcs -x share

install: 
	install -d /usr/local/share/clog/agents
	install share/* /usr/local/share/clog/agents
	install -d /etc/clog
	[ -f /etc/clog/clog.conf ] || install etc/clog.conf /etc/clog
	install -d /usr/local/bin
	install bin/clog.rb /usr/local/bin/clog

.PHONY: test install doc
