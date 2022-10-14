Name:		springboot-selinux-devel
Version:	%{_provided_version}
Release:	%{_provided_release}%{?dist}
Summary:	SELinux policy module for Springboot applications - devel
License:	GPLv2
URL:		https://github.com/hubertqc/selinux_springboot
#Source:	%{name}-%{version}.tar.gz
BuildArch:	noarch

Requires:	selinux-policy-devel
Requires:	springboot-selinux = %{version}-%{release}

%description
SELinux policy development interface for Springboot policy module.

###################################

%clean
%{__rm} -rf %{buildroot}

#%prep
#%setup -q

###################################

%install

mkdir -p -m 0755 %{buildroot}/usr/share/selinux/devel/include/apps

install -m 0444 %{_builddir}/se_module/springboot.if %{buildroot}/usr/share/selinux/devel/include/apps/

###################################

%files
%defattr(-,root,root,-)

/usr/share/selinux/devel/include/apps/springboot.if