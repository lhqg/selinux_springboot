SELinux policy module for Springboot applications
==========================================================
https://github.com/hubertqc/selinux_springboot

## Introduction

This SELinux policy module aims to prevent a Springboot (daemon/background) application to
 perform unexpected actions on a Linux host.

It should be used when the Springboot application is possibly exposed to a world full of
 *bad guys*.

The module should prevent the application from going rogue, and should the application be
compromised by an attacker this SELinux policy module should help limit the damage on the
system on which the Springboot application is running.

When used correctly, this SELinux policy module will make the Springboot application(s)
run on the host in the dedicated `springboot_t` SELinux domain.

## How to use this SELinux module

Once the SELinux policy module is compiled and installed in the running Kernel SELinux
 policy, a few actions must be taken for the new policy to apply to the Springboot
 application(s).
 
The policy can be adjusted with a handfull of SELinux booleans.

### Filesystem labelling
This SELinux policy module SELinux file context definitions are based on the Filesystem 
Hierarchy Standards [https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard].

The root for the Springboot installation is expected to be /opt/springboot.
The root for log files of the Springboot application(s) is expected to be
 /var/log/springboot.

A typical directory layout for the Springboot application `my_app` would be:

```
/opt/springboot/my_app
                      \ conf
                      \ lib
                      \ keys
                      
/var/log/springboot/my_app

/var/run/springboot/my_app

/srv/springboot/my_app
                      \ cache
                      \ work
                      \ dynlib
                      
```

Files with a 

Files with `.so` and `.jar` extensions under the /opt/springboot and /srv/springboot trees
will be assigned the *Springboot library* SELinux type.

Files with `.jks`, `.jceks`, `.p12` or `.pkcs12`extensions placed in a `conf`or
 `properties` directory under /opt/springboot will be assigned the *Springboot 
 authentication/credentials* SELinux type. All files located in a `keys`directory under
  /opt/springboot will be assigned the same SELinux type.


Should you prefer to used a different directory structure, you should consider using
SELinux fcontext equivalence rules to map your specifics to the filesystem layout expected
in the policy module, using the `semanage fcontext -a -e ORIGINAL CUSTOMISATION` command.

### Network ports

The TCP port the Springboot application binds and listens too should be assigned the
 `springboot_port_t`SELinux type.

### SELinux booleans

#### allow_springboot_dynamic_libs		(default: `false`)
#### allow_springboot_purge_logs		(default: `false`)
#### allow_webadm_read_springboot_files		(default: `false`)
#### allow_sysadm_write_springboot_files	(default: `false`)

### Starting the Springboot application


/(lib|etc)/systemd/system/springboot@?.*					gen_context(system_u:object_r:springboot_unit_file_t,s0)
/opt/springboot/bin/springboot_service					--	gen_context(system_u:object_r:springboot_exec_t,s0)
/opt/springboot/service/.*						--	gen_context(system_u:object_r:springboot_exec_t,s0)


### Running multiple Springboot appplications on the same host

TO DO


## Disclaimer

The code of the this SELinux policy module is provided AS-IS. People and organisation
willing to use it must be fulling aware that they are doing it at their own risks and
expenses.

The Author(s) of this SELinux policy module SHALL NOT be held liable nor accountable, in
 any way, of any malfunction or limitation of said module, nor of the resulting damage, of
 any kind, resulting, directly or indirectly, of the usage of this SELinux policy module.

It is strongly advised to always use the last version of the code, to check for the 
compatibility of the platform where it is about to be deployed, to compile the module on
the target specific Linux distribution and version where it is intended to be used.

Finally, users should check regularly for updates.
