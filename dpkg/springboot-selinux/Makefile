NAME := springboot-selinux
SOURCEDIR := %sourcedir%
BUILDDIR := %builddir%/debian
DOCDIR := /usr/share/doc
DATAROOTDIR := /usr/share

compile:
	@make -f /usr/share/selinux/devel/Makefile -C $(SOURCEDIR)/se_module springboot.pp
	@bzip2 $(SOURCEDIR)/se_module/springboot.pp

install: compile
	@mkdir -p -m 0755 $(BUILDDIR)/usr/share/selinux/packages/targeted
	@mkdir -p -m 0755 $(BUILDDIR)/usr/share/man/man8
	@mkdir -p -m 0755 $(BUILDDIR)/$(DOCDIR)/$(NAME)
	@mkdir -p -m 0755 $(BUILDDIR)/$(DATAROOTDIR)/$(NAME)

	@install -m 0555 $(SOURCEDIR)/scripts/* $(BUILDDIR)/$(DATAROOTDIR)/$(NAME)/
	@install -m 0444 $(SOURCEDIR)/se_module/springboot.pp.bz2 $(BUILDDIR)/usr/share/selinux/default/
	@install -m 0444 $(SOURCEDIR)/LICENSE $(BUILDDIR)/$(DOCDIR)/$(NAME)/
	@install -m 0444 $(SOURCEDIR)/README.md $(BUILDDIR)/$(DOCDIR)/$(NAME)/
	@install -m 0444 $(SOURCEDIR)/manpages/man8/*.8 $(BUILDDIR)/usr/share/man/man8/
