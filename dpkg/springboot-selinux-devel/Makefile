NAME := springboot-selinux-devel
SOURCEDIR := %sourcedir%
BUILDDIR := %builddir%/debian
DOCDIR := /usr/share/doc
DATAROOTDIR := /usr/share

install: 
	@mkdir -p -m 0755 $(BUILDDIR)/usr/share/selinux/devel/include/apps
	@install -m 0444 $(SOURCEDIR)/se_module/springboot.if $(BUILDDIR)/usr/share/selinux/devel/include/apps/
