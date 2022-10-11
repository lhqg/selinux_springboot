Name:      springboot-selinux
Version:   %{provided_version}
Release:   %{provided_release}%{?dist}
Summary:	 SELinux policy module for Springboot applications
License:	 GPLv2
URL:       https://github.com/hubertqc/selinux_springboot
Source:    %{name}-%{version}.tar.gz
BuildArch: noarch

Requires:	selinux-policy-devel
Requires:	selinux-policy-targeted
Requires:	policycoreutils
Requires:	make

%description
SELinux policy module to confine Springboot applications started using systemd.
The systemd service unit name must start with springboot, the start script must be 
assigned the springboot_exec_t SELinux type.
The Springboot application will run in the springboot_t domain.

%clean
%{__rm} -rf %{buildroot}

%prep
%setup -q

%build

make -f /usr/share/selinux/devel/Makefile -C %{_sourcedir} springboot.pp

%install
mkdir -p -m 0755 %{buildroot}/usr/share/selinux/packages/targeted
mkdir -p -m 0755 %{buildroot}/usr/share/selinux/devel/include/apps

install -m 0444 %{_sourcedir}/springboot.if %{buildroot}/usr/share/selinux/devel/include/apps/

bzip2 %{_sourcedir}/springboot.pp
install -m 0444 %{_sourcedir}/springboot.pp.bz2 %{buildroot}/usr/share/selinux/packages/targeted/

%post

mkdir -m 0700 /tmp/selinux-springboot
bzcat -dc /usr/share/selinux/packages/targeted/springboot.pp.bz2 > /tmp/selinux-springboot/springboot.pp
semodule -i /tmp/selinux-springboot/springboot.pp
rm -rf /tmp/selinux-springboot

%postun
semodule -r springboot

%files
%defattr(-,root,root,-)
/usr/share/selinux/devel/include/apps/springboot.if
/usr/share/selinux/packages/targeted/springboot.pp.bz2

%license LICENSE
%doc    README.md
