NAME := springboot-selinux
SOURCEDIR := %sourcedir%
DESTDIR ?= %builddir%/debian/%name%
DOCDIR := /usr/share/doc
DATAROOTDIR := /usr/share

install:
	@make -f /usr/share/selinux/devel/Makefile -C $(SOURCEDIR)/se_module clean
	@rm -f $(SOURCEDIR)/se_module/springboot.pp.bz2

	@make -f /usr/share/selinux/devel/Makefile -C $(SOURCEDIR)/se_module springboot.pp
	@bzip2 $(SOURCEDIR)/se_module/springboot.pp

	@mkdir -p -m 0755 $(DESTDIR)/usr/share/selinux/default
	@mkdir -p -m 0755 $(DESTDIR)/usr/share/man/man8
	@mkdir -p -m 0755 $(DESTDIR)/$(DOCDIR)/$(NAME)
	@mkdir -p -m 0755 $(DESTDIR)/$(DATAROOTDIR)/$(NAME)

	@install -m 0555 $(SOURCEDIR)/scripts/* $(DESTDIR)/$(DATAROOTDIR)/$(NAME)/
	@install -m 0444 $(SOURCEDIR)/se_module/springboot.pp.bz2 $(DESTDIR)/usr/share/selinux/default/
	@install -m 0444 $(SOURCEDIR)/LICENSE $(DESTDIR)/$(DOCDIR)/$(NAME)/
	@install -m 0444 $(SOURCEDIR)/README.md $(DESTDIR)/$(DOCDIR)/$(NAME)/
	@install -m 0444 $(SOURCEDIR)/manpages/man8/*.8 $(DESTDIR)/usr/share/man/man8/
