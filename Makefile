TARGETS := $(shell ls scripts | grep -v server)

.dapper:
	@echo Downloading dapper
	@curl -sL https://releases.rancher.com/dapper/latest/dapper-`uname -s`-`uname -m` > .dapper.tmp
	@@chmod +x .dapper.tmp
	@./.dapper.tmp -v
	@mv .dapper.tmp .dapper

shell: .dapper
	rm -rf .bash_history
	./.dapper -m bind -s

$(TARGETS): .dapper
	./.dapper -m bind $@

server:
	docker image build . -f Dockerfile.dapper -t website
	docker run -it --mount type=bind,source="$(shell pwd)",target=/website --entrypoint="/bin/bash" -p 1313:1313 website /website/scripts/server


.DEFAULT_GOAL := ci

.PHONY: $(TARGETS) server

