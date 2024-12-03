NAME := springboot-systemd
SOURCEDIR := %sourcedir%
DESTDIR ?= %builddir%/debian/%name%
DOCDIR := /usr/share/doc
DATAROOTDIR := /usr/share

install: 
	@mkdir -p -m 0755 $(DESTDIR)/usr/lib/systemd/system
	@mkdir -p -m 0755 $(DESTDIR)/usr/lib/systemd/system-preset
	@mkdir -p -m 0755 $(DESTDIR)/opt/springboot/bin
	@mkdir -p -m 0755 $(DESTDIR)/opt/springboot/service
	@mkdir -p -m 0755 $(DESTDIR)/usr/share/man/man7
	@mkdir -p -m 0755 $(DESTDIR)/$(DOCDIR)/$(NAME)/examples

	@install -m 0444 $(SOURCEDIR)/systemd/springboot@.service $(DESTDIR)/usr/lib/systemd/system/
	@install -m 0444 $(SOURCEDIR)/systemd/springboot.target $(DESTDIR)/usr/lib/systemd/system/
	@install -m 0444 $(SOURCEDIR)/systemd/springboot.preset $(DESTDIR)/usr/lib/systemd/system-preset/90-springboot.preset
	@install -m 0444 $(SOURCEDIR)/systemd/springboot-shutdown.target $(DESTDIR)/usr/lib/systemd/system/
	@install -m 0555 $(SOURCEDIR)/systemd/springboot-service.sh $(DESTDIR)/opt/springboot/bin/

	@install -m 0444 $(SOURCEDIR)/systemd/env.SAMPLE $(DESTDIR)/$(DOCDIR)/$(NAME)/examples/

	@install -m 0444 $(SOURCEDIR)/LICENSE $(DESTDIR)/$(DOCDIR)/$(NAME)/
	@install -m 0444 $(SOURCEDIR)/manpages/man7/$(NAME).7 $(DESTDIR)/usr/share/man/man7/
