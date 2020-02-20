TARGETS := $(shell ls scripts | grep -v server)

hugo:
	@echo Downloading hugo wrapper 
	@curl -L -o hugo https://github.com/khos2ow/hugo-wrapper/releases/download/v1.4.0/hugow
	@@chmod +x hugo

server: hugo
	./hugo server -w -s src

static: hugo
	./hugo -D -s src -d ../output


.DEFAULT_GOAL := static 

.PHONY: static server

