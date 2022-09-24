SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
srcdir = Sources

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
STYLE = debug
SOURCES = $(wildcard $(srcdir)/**/*.swift)

.DEFAULT_GOAL = all

.PHONY: all
all: swift-doctest

swift-doctest: $(SOURCES)
	@swift build \
        --configuration "$(STYLE)" \
		--disable-sandbox \
		--scratch-path "$(BUILDDIR)"

.PHONY: install
install: swift-doctest
	@install -d "$(bindir)"
	@install "$(BUILDDIR)/$(STYLE)/SwiftDocTest" "$(bindir)"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/SwiftDocTest"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/$(STYLE)

.PHONY: clean
clean: distclean
	@rm -rf $(BUILDDIR)
