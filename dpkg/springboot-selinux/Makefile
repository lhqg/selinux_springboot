NAME := springboot-selinux
SOURCEDIR := %sourcedir%
BUILDDIR := %builddir%/debian
DOCDIR := /usr/share/doc
DATAROOTDIR := /usr/share

build:
	@make -f /usr/share/selinux/devel/Makefile -C $(BUILDDIR)/se_module springboot.pp
	@bzip2 $(BUILDDIR)/se_module/springboot.pp

install: build
	@mkdir -p -m 0755 $(INSDIR)/usr/share/selinux/packages/targeted
	@mkdir -p -m 0755 $(INSDIR)/usr/share/man/man8
	@mkdir -p -m 0755 $(INSDIR)/$(DOCDIR)/$(NAME)
	@mkdir -p -m 0755 $(INSDIR)/$(DATAROOTDIR)/$(NAME)

	@install -m 0555 $(BUILDDIR)/scripts/* $(INSDIR)/$(DATAROOTDIR)/$(NAME)/
	@install -m 0444 $(BUILDDIR)/se_module/springboot.pp.bz2 $(INSDIR)/usr/share/selinux/default/
	@install -m 0444 $(BUILDDIR)/LICENSE $(INSDIR)/$(DOCDIR)/$(NAME)/
	@install -m 0444 $(BUILDDIR)/README.md $(INSDIR)/$(DOCDIR)/$(NAME)/
	@install -m 0444 $(BUILDDIR)/manpages/man8/*.8 $(INSDIR)/usr/share/man/man8/
