test:
	sed "s:/etc/clog/filters:lib:" etc/clog.conf > test/clog.conf
	ruby bin/clog.rb -C -c test/clog.conf

install: 
	install -d /etc/clog/filters
	install lib/* /etc/clog/filters
	[ -f /etc/clog/clog.conf ] || install etc/clog.conf /etc/clog
	install -d /usr/local/bin
	install bin/clog.rb /usr/local/bin/clog
.PHONY: test install
