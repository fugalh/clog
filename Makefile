rdoc=rdoc1.8
test: agents
	echo "# this file is generated" > test/clog.conf
	sed "s:/usr/local/share/clog/agents:share:" examples/clog.conf >> test/clog.conf
	ruby -Ilib bin/clog.rb -C -c test/clog.conf

agents:
	> lib/clog/agents.rb
	for i in lib/clog/agents/*.rb; do echo "require 'clog/agents/`basename $$i .rb`'" >> lib/clog/agents.rb; done

doc: agents
	${rdoc} lib bin

.config:
	ruby setup.rb config --prefix=/usr/local --siteruby=/usr/local/lib/site_ruby

config: .config

install: config
	ruby setup.rb install

.PHONY: test install doc config agents
