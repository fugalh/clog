rdoc=rdoc1.8
test:
	echo "# this file is generated" > test/clog.conf
	sed "s:/usr/local/share/clog/agents:share:" examples/clog.conf >> test/clog.conf
	ruby -Ilib bin/clog -C -c test/clog.conf

doc:
	${rdoc} -m lib/clog.rb -t "clog documentation" bin lib

.config:
	ruby setup.rb config --prefix=/usr/local --siteruby=/usr/local/lib/site_ruby

config: .config

install: config
	ruby setup.rb install

clean:
	ruby setup.rb clean
	rm -rf doc

show: .config
	ruby setup.rb show

.PHONY: test install doc config clean show
