PORT ?= 1313
BIND ?= localhost
OPEN_CMD := $(shell command -v open || command -v xdg-open || echo : 2>/dev/null)
HUGO_VERSION := v0.71.0
OUTPUT_DIR:=/

hugo:
	@echo Downloading hugo wrapper 
	@curl -L -o hugo https://github.com/khos2ow/hugo-wrapper/releases/download/v1.4.0/hugow
	@@chmod +x hugo
	@./hugo --get-version $(HUGO_VERSION)

server: hugo
	(sleep 2; $(OPEN_CMD) http://localhost:$(PORT)) &
	./hugo server -w -s src --bind=$(BIND) --port=$(PORT)

static: hugo
	./hugo -D -s src -b $(OUTPUT_DIR) -d ../output/$(OUTPUT_DIR)

static-all: hugo
	./scripts/make-all-versions # we use a script because we expect that changes could happen on makefiles

CODEOWNERS: CODEOWNERS.in
	$(CURDIR)/scripts/gen-codeowners

.DEFAULT_GOAL := static 

.PHONY: static server

