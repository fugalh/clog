rdoc=rdoc1.8
test:
	echo "# this file is generated" > test/clog.conf
	sed "s:/etc/clog/agents:lib:" etc/clog.conf >> test/clog.conf
	ruby bin/clog.rb -C -c test/clog.conf

doc:
	${rdoc} -x _darcs -x lib

install: 
	install -d /etc/clog/agents
	install lib/* /etc/clog/agents
	[ -f /etc/clog/clog.conf ] || install etc/clog.conf /etc/clog
	install -d /usr/local/bin
	install bin/clog.rb /usr/local/bin/clog

.PHONY: test install doc
