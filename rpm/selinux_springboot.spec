Name:		springboot-selinux
Version:	%{_provided_version}
Release:	%{_provided_release}%{?dist}
Summary:	SELinux policy module for Springboot applications
License:	GPLv2
URL:		https://github.com/hubertqc/selinux_springboot
#Source:	%{name}-%{version}.tar.gz
BuildArch:	noarch

BuildRequires:	selinux-policy-devel
BuildRequires:	make

Requires:	selinux-policy-targeted %{?_sepol_minver_cond}
Requires:	selinux-policy-targeted %{?_sepol_maxver_cond}

Requires:	policycoreutils
Requires:	policycoreutils-python-utils
Requires:	libselinux-utils

%description
SELinux policy module to confine Springboot applications started using systemd.
The systemd service unit name must start with springboot, the start script must be 
assigned the springboot_exec_t SELinux type.
The Springboot application will run in the springboot_t domain.

###################################

%clean
%{__rm} -rf %{buildroot}

#%prep
#%setup -q

###################################

%build

make -f /usr/share/selinux/devel/Makefile -C %{_builddir} springboot.pp

###################################

%install

mkdir -p -m 0755 %{buildroot}/usr/share/selinux/packages/targeted
mkdir -p -m 0755 %{buildroot}/usr/share/selinux/devel/include/apps
mkdir -p -m 0755 %{buildroot}/%{_docdir}/%{name}
mkdir -p -m 0755 %{buildroot}/%{_datarootdir}/%{name}

install -m 0444 %{_builddir}/se_module/springboot.if %{buildroot}/usr/share/selinux/devel/include/apps/
install -m 0555 %{_builddir}/scripts/* %{buildroot}/%{_datarootdir}/%{name}/

install -m 0444 %{_builddir}/springboot.pp %{buildroot}/usr/share/selinux/packages/targeted/

install -m 0444 %{_builddir}/{LICENSE,README.md} %{buildroot}/%{_docdir}/%{name}/

###################################

%post

semodule -i /usr/share/selinux/packages/targeted/springboot.pp

if selinuxenabled
then
  restorecon -RFi /{opt,srv}/springboot 
  restorecon -RFi /{lib,etc}/systemd/system/springboot*
  restorecon -RFi /var/{lib,log,run,tmp}/springboot
fi

###################################

%postun

if [ $1 -eq 0 ]
then
  semodule -r springboot
fi

###################################

%files
%defattr(-,root,root,-)

/usr/share/selinux/devel/include/apps/springboot.if
/usr/share/selinux/packages/targeted/springboot.pp

%dir %{_datarootdir}/%{name}
%{_datarootdir}/%{name}/*

%dir %{_docdir}/%{name}
%license  %{_docdir}/%{name}/LICENSE
%doc      %{_docdir}/%{name}/README.md
