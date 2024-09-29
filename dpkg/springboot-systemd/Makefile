NAME := springboot-systemd
SOURCEDIR := %sourcedir%
BUILDDIR := %builddir%/debian
DOCDIR := /usr/share/doc
DATAROOTDIR := /usr/share

install: 
	@mkdir -p -m 0755 $(BUILDDIR)/usr/lib/systemd/system
	@mkdir -p -m 0755 $(BUILDDIR)/opt/springboot/bin
	@mkdir -p -m 0755 $(BUILDDIR)/opt/springboot/service
	@mkdir -p -m 0755 $(BUILDDIR)/usr/share/man/man7
	@mkdir -p -m 0755 $(BUILDDIR)/$(DOCDIR)/$(NAME)/examples

	@install -m 0444 $(SOURCEDIR)/systemd/springboot@.service $(BUILDDIR)/usr/lib/systemd/system/
	@install -m 0444 $(SOURCEDIR)/systemd/springboot.target $(BUILDDIR)/usr/lib/systemd/system/
	@install -m 0444 $(SOURCEDIR)/systemd/springboot-shutdown.target $(BUILDDIR)/usr/lib/systemd/system/
	@install -m 0555 $(SOURCEDIR)/systemd/springboot-service.sh $(BUILDDIR)/opt/springboot/bin/

	@install -m 0444 $(SOURCEDIR)/systemd/env.SAMPLE $(BUILDDIR)/$(DOCDIR)/$(NAME)/examples/

	@install -m 0444 $(SOURCEDIR)/LICENSE $(BUILDDIR)/$(DOCDIR)/$(NAME)/
	@install -m 0444 $(SOURCEDIR)/manpages/man7/$(NAME).7 $(BUILDDIR)/usr/share/man/man7/
