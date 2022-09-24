SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
srcdir = Sources

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
SOURCES = $(wildcard $(srcdir)/**/*.swift)

.DEFAULT_GOAL = all

.PHONY: all
all: swift-doctest

swift-doctest: $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--scratch-path "$(BUILDDIR)"

.PHONY: install
install: swift-doctest
	@install -d "$(bindir)"
	@install "$(BUILDDIR)/release/SwiftDocTest" "$(bindir)"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/SwiftDocTest"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release

.PHONY: clean
clean: distclean
	@rm -rf $(BUILDDIR)
