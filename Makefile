URL := http://localhost:1313
OPEN_CMD := $(shell command -v open || command -v xdg-open || echo : 2>/dev/null)

hugo:
	@echo Downloading hugo wrapper 
	@curl -L -o hugo https://github.com/khos2ow/hugo-wrapper/releases/download/v1.4.0/hugow
	@@chmod +x hug # BREAKING ON PURPOSE TEST

server: hugo
	(sleep 2; $(OPEN_CMD) $(URL)) &
	./hugo server -w -s src

static: hugo
	./hugo -D -s src -d ../output


.DEFAULT_GOAL := static 

.PHONY: static server

