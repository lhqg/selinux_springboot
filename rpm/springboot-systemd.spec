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

#%prep
#%setup -q

###################################

%install

mkdir -p -m 0755 %{buildroot}/%{_docdir}/%{name}/examples
mkdir -p -m 0755 %{buildroot}/usr/lib/systemd/system
mkdir -p -m 0755 %{buildroot}/opt/springboot/bin
mkdir -p -m 0755 %{buildroot}/opt/springboot/service

install -m 0444 %{_builddir}/systemd/springboot@.service %{buildroot}/usr/lib/systemd/system/
install -m 0444 %{_builddir}/systemd/springboot.target %{buildroot}/usr/lib/systemd/system/
install -m 0444 %{_builddir}/systemd/springboot-shutdown.target %{buildroot}/usr/lib/systemd/system/
install -m 0555 %{_builddir}/systemd/springboot-service.sh %{buildroot}/opt/springboot/bin/

install -m 0444 %{_builddir}/systemd/env.SAMPLE %{buildroot}/%{_docdir}/%{name}/examples/

###################################

%post

systemctl daemon-reload

if selinuxenabled
then
  restorecon -Fi /opt/springboot/bin/springboot-service.sh
  restorecon -RFi /{lib,etc}/systemd/system/springboot*
  restorecon -RFi %{_docdir}/%{name}/
fi
  
###################################

%files
%defattr(-,root,root,-)

/usr/lib/systemd/system/springboot@.service
/usr/lib/systemd/system/springboot.target
/usr/lib/systemd/system/springboot-shutdown.target
/opt/springboot/bin/springboot-service.sh
  
%dir		%{_docdir}/%{name}
%doc		%{_docdir}/%{name}/examples/env.SAMPLE

