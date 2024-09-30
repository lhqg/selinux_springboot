NAME := springboot-selinux-devel
SOURCEDIR := %sourcedir%
DESTDIR ?= %builddir%/debian/%name%
DOCDIR := /usr/share/doc
DATAROOTDIR := /usr/share

install: 
	@mkdir -p -m 0755 $(DESTDIR)/usr/share/selinux/devel/include/apps
	@install -m 0444 $(SOURCEDIR)/se_module/springboot.if $(DESTDIR)/usr/share/selinux/devel/include/apps/
