Name:		springboot-systemd
Version:	%{_provided_version}
Release:	%{_provided_release}%{?dist}
Summary:	Springboot systemd units
Vendor:   LHQG, https://www.lhqg.fr/
License:	GPLv3
URL:		https://github.com/lhqg/selinux_springboot
#Source:	%{name}-%{version}.tar.gz
BuildArch:	noarch

Requires:	systemd
Requires:	springboot-selinux = %{version}-%{release}

%description
Definitions of systemd units for Springboot applications.

###################################

%clean
%{__rm} -rf %{buildroot}

###################################

%pre

getent group springboot >/dev/null || groupadd -r springboot
getent passwd springboot >/dev/null || useradd -r -g springboot -s /sbin/nologin -d /home/springboot -c "Springboot" springboot
exit 0

###################################

%install

mkdir -p -m 0755 %{buildroot}/%{_docdir}/%{name}/examples
mkdir -p -m 0755 %{buildroot}/usr/lib/systemd/system
mkdir -p -m 0755 %{buildroot}/usr/lib/systemd/system-preset
mkdir -p -m 0755 %{buildroot}/opt/springboot/bin
mkdir -p -m 0755 %{buildroot}/opt/springboot/service
mkdir -p -m 0755 %{buildroot}/usr/share/man/man7

install -m 0444 %{_builddir}/systemd/springboot@.service %{buildroot}/usr/lib/systemd/system/
install -m 0444 %{_builddir}/systemd/springboot.target %{buildroot}/usr/lib/systemd/system/
install -m 0444 %{_builddir}/systemd/springboot.preset %{buildroot}/usr/lib/systemd/system-preset/90-springboot.preset
install -m 0444 %{_builddir}/systemd/springboot-shutdown.target %{buildroot}/usr/lib/systemd/system/
install -m 0555 %{_builddir}/systemd/springboot-service.sh %{buildroot}/opt/springboot/bin/
install -m 0444 %{_builddir}/manpages/man7/*.7 %{buildroot}/usr/share/man/man7/

install -m 0444 %{_builddir}/systemd/env.SAMPLE %{buildroot}/%{_docdir}/%{name}/examples/

###################################

%post

if selinuxenabled
then
  restorecon -Fi /opt/springboot/bin/springboot-service.sh
  restorecon -RFi /{lib,etc}/systemd/system/springboot*
  restorecon -RFi /{lib,etc}/systemd/system-preset/*springboot.preset
  restorecon -RFi %{_docdir}/%{name}/
fi

systemctl daemon-reload
  
###################################

%files
%defattr(-,root,root,-)

/usr/lib/systemd/system/springboot@.service
/usr/lib/systemd/system/springboot.target
/usr/lib/systemd/system/springboot-shutdown.target
/usr/lib/systemd/system-preset/90-springboot.preset
/opt/springboot/bin/springboot-service.sh
  
%dir		%{_docdir}/%{name}
%doc		%{_docdir}/%{name}/examples/env.SAMPLE
%doc		/usr/share/man/man*/*

