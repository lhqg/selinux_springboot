Name:		springboot-selinux
Version:	#{version}#
Release:        1%{?dist}
Summary:	SELinux policy module for Springboot applications
License:	GPLv2
URL: 		https://github.com/hubertqc/selinux_springboot
Source0:	https://github.com/hubertqc/selinux_springboot/archive/refs/tags/v%{version}.tar.gz
BuildArch:	noarch

BuildRequires:	selinux-policy-devel
BuildRequires:	make

Requires:	selinux-policy-devel
Requires:	selinux-policy-targeted
Requires:	policycoreutils

%description
SELinux policy module to confine Springboot applications started using systemd.
The systemd service unit name must start with springboot, the start script must be 
assigned the springboot_exec_t SELinux type.
The Springboot application will run in the springboot_t domain.

%prep
%setup -q -n selinux_springboot-%{version}

%build

mkdir -p -m 0755 %{buildroot}/usr/share/selinux/packages/targeted
mkdir -p -m 0755 %{buildroot}/usr/share/selinux/devel/include/apps

install -m 0444 se_module/springboot.if %{buildroot}/usr/share/selinux/devel/include/apps/springboot.if
cd se_module/ && tar cfvj %{buildroot}/usr/share/selinux/packages/targeted/springboot.pp.bz2 springboot.te springboot.fc

%post
mkdir -m 0700 /tmp/selinux-springboot
cd /tmp/selinux-springboot/ && tar xfj /usr/share/selinux/packages/targeted/springboot.pp.bz2
make -f /usr/share/selinux/devel/Makefile springboot.pp
semodule -i springboot.pp
bzip2 springboot.pp
mv springboot.pp.bz2 /usr/share/selinux/packages/targeted/
cd /tmp
rm -rf /tmp/selinux-springboot

%postun
semodule -r springboot

%files
/usr/share/selinux/devel/include/apps/springboot.if
%verify(not size filedigest mtime) /usr/share/selinux/packages/targeted/springboot.pp.bz2

%license LICENSE
%doc    README.md