test:
	sed "s:/etc/clog/filters:lib:" etc/clog.conf > test/clog.conf
	ruby bin/clog.rb -C -c test/clog.conf

.PHONY: test
