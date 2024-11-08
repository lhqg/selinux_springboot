![GitHub Release (latest SemVer)](https://img.shields.io/github/v/release/lhqg/selinux_springboot)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![GitHub Issues](https://img.shields.io/github/issues/lhqg/selinux_springboot)](https://github.com/lhqg/selinux_springboot/issues)
[![GitHub PR](https://img.shields.io/github/issues-pr/lhqg/selinux_springboot)](https://github.com/lhqg/selinux_springboot/pulls)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/lhqg/selinux_springboot)](https://github.com/lhqg/selinux_springboot/commits/main)
[![GitHub Last commit](https://img.shields.io/github/last-commit/lhqg/selinux_springboot)](https://github.com/lhqg/selinux_springboot/commits/main)
![GitHub Downloads](https://img.shields.io/github/downloads/lhqg/selinux_springboot/total)

# SELinux policy module for Springboot (Spring Boot) applications

Maintained and provided as a community contribution by [LHQG](https://www.lhqg.fr/).

## Table of Contents

1. [Introduction](#introduction)
2. [How to use this SELinux module](#how-to-use-this-selinux-module)
    * [Filesystem labelling](#filesystem-labelling)
    * [Networking](#networking)
        * [Listen port](#listen-port)
        * [Monitoring port](#monitoring-port)
        * [Services consumed bu the Springboot application](#services-consumed-by-the-springboot-application)
    * [SELinux booleans](#selinux-booleans)
    * [Interfaces for deployment tools](#interfaces-for-deployment-tools)
    * [Starting the Springboot application](#starting-the-springboot-application)
3. [Running multiple Springboot applications on the same host](#running-multiple-springboot-applications-on-the-same-host)
4. [Related projects](#related-projects)
5. [Disclaimer](#disclaimer)

## Introduction

This SELinux policy module aims to prevent a Java Spring Boot (daemon/background)
application to perform unexpected actions on a Linux host.

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

```filesystem
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

Files with `.so` and `.jar` extensions under the /opt/springboot and /srv/springboot trees
will be assigned the *Springboot library* SELinux type.

Files with `.jks`, `.jceks`, `.p12` or `.pkcs12` extensions placed in a `conf` or
`properties` directory under /opt/springboot will be assigned the *Springboot
authentication/credentials* SELinux type `springboot_auth_t`.
All files located in a `keys` directory under /opt/springboot will be assigned this SELinux
 type. You may want to assign this type, using fcontext customizations, to your sensitive
 files containing authentication data for your Springboot application (passwords, private keys,
 tokens, ...).
 Such files can only be read by the Springboot application, deployment tools (Ansible, Puppet, ...)
 will need specific permissions to create/modify them.
 (See also boolean `allow_sysadm_manage_springboot_auth_files` below).

Should you prefer to use a different directory structure, you should consider using
SELinux fcontext equivalence rules to map your specifics to the filesystem layout expected
in the policy module, using the `semanage fcontext -a -e ORIGINAL CUSTOMISATION` command.

### Networking

#### Listen port

The TCP port the Springboot application binds and listens to MUST be assigned the
 `springboot_port_t` SELinux type.

#### Monitoring port

If the Springboot application needs to bind and listen to a specific port to offer
monitoring metrics and information, then this TCP port should be assigned the
`springboot_monitoring_port_t` SELinux type.

Then, (host)local processes need to be granted the permission to connect to the monitoring
port using the policy module interface `springboot_monitor()` with the SELinux domain
prefix as the only argument.

Example: `springboot_monitoring_port_t(zabbix)` to Allow Zabbix to connect to the
monitoring port of the Springboot application.

#### Services consumed by the Springboot application

If the application needs to connect to services such as databases, directory servers, ...
the SELinux type of these services network port must be allowed for the Springboot
application to connect to.
One of the `springboot_allow_connectto` or `springboot_allow_consumed_service` interfaces
should be used with the prefix name for the service as the only argument.

Examples:

* `springboot_allow_connectto(postgresql)` to allow the Springboot application to connect to a PostgreSQL database
* `springboot_allow_connectto(ldap)` to allow connection to LDAP directory services.

### SELinux booleans

#### allow_springboot_connectto_http      (default: `true`)

When switched to `true`, this boolean allows the Springboot application to connect to remote
HTTP/HTTPS ports (locally assigned the `http_port_t` SELinux type).

#### allow_springboot_connectto_self      (default: `false`)

When switched to `true`, this boolean allows the Springboot application to connect to other remote
Springboot application (locally assigned the `springboot_port_t` SELinux type).

#### allow_springboot_syslog_netsend      (default: `false`)

When switched to `true`, this boolean allows the Springboot application to use the syslog protocol to send log
messages (both UDP and TCP transports).

#### allow_springboot_connectto_ldap      (default: `false`)

When switched to `true`, this boolean allows the Springboot application to connect to remote
LDAP/LDAPS ports (locally assigned the `ldap_port_t` SELinux type).

#### allow_springboot_connectto_smtp      (default: `false`)

When switched to `true`, this boolean allows the Springboot application to connect to remote
SMTP/SMTPS/submission ports (locally assigned the `smtp_port_t` SELinux type).

#### Mutiple booleans allow_springboot_connectto_\<DB\>      (default: `false`)

When switched to `true`, these boolean allows the Springboot application to connect to remote
database server ports: `couchdb`, `mongodb`, `mysql` (MariaDB), `oracle`, `pgsql` (PostgreSQL), `redis`.

#### allow_springboot_dynamic_libs  (default: `false`)

When switched to `true`, this boolean allows the Springboot application to create and use
(execute) SO libraries and JAR files under the /srv/springboot/.../dynlib directory.
Use with care, i.e. only when strictly required, as this would allow a compromised
Springboot application to offload arbitrary code and use it.

#### allow_springboot_purge_logs  (default: `false`)

When switched to `true`, this boolean allows the Springboot application to delete its log
files. It can be useful for "in Java app" logging framework initiated log file rotation.
But it can also be useful for attackers who would like to clean after themselves and remove traces of their actions...

#### allow_springboot_rewrite_logs  (default: `false`)

When switched to `true`, this boolean allows the Springboot application to rewrite its own
log files. It can prove useful when the logging framework cannot work in "append only" mode".
But it can also be useful for attackers who would like to clean after themselves and remove traces of their actions...

#### allow_webadm_read_springboot_files  (default: `false`)

Users running with the `webadm_r` SELinux role and`webadm_t` domain are granted the
permissions to browse the directories of the Springboot application and the permission to
stop and start the Springboot application **systemd** services, as well as querying their
status.

When switched to `true`, this boolean allows such users additional permissions to read the
contents of Springboot application files: log, configuration, temp and transient/cache
files.

#### allow_sysadm_write_springboot_files (default: `false`)

When switched to `true`, this boolean allows users running with the `sysadm_r` SELinux role
and `sysadm_t` domain to:

* fully manage temporary files,
* delete and rename log files,
* delete and rename transient/cache files,
* modify the contents of configuration files,

Otherwise, such users are only granted read permissions on all Springboot application
files, except authentication/credentials files.

#### allow_sysadm_manage_springboot_auth_files (default: `false`)

When switched to `true`, this boolean allows users running with the `sysadm_r` SELinux role
and `sysadm_t` domain to fully manage Springboot authentication files.

### Interfaces for deployment tools

When the deployment tool (Ansible, Puppet, ...) for the Springboot application runs not unconfined on the target host,
it becomes necessary to grant it permissions to create/modify/delete the Springboot application files.
This is achieved using SELinux code interfaces to create and compile small additionnal SELinux policy modules.

For obvious security reasons, the deployment tool should not be allowed to delete log files.

Each interface takes the SELinux domain prefix of the deployment tool as its first argument.
Eg: `ansible` for Ansible if the SELinux domain is `ansible_t`.

#### `springboot_deployer` interface

This interface grants permissions to deploy (create/read/write) and clean up (delete) Springboot application files and directories.
It also allows the deployment tool to manage the Springboot systemd units (services/targets/...).

The scope of actions on the main Linux operating system directories is limited to:

* create a `springboot` subdirectory under /opt, /var/lib, /var/log, /srv, /run, ...
* create subdirectories in the `springboot` directores above.

The scope of actions on Springboot application files and directories is limited to the following types:

* fully manage configuration files (and symlinks)
* fully manage transient (tmp, run) files (and symlinks)
* fully manage application (bin, lib, dynlibs) files (and symlinks)

The scope of actions on the systemd units is limited to:

* read the Springboot systemd unit files (and diretcories)
* stop/start/query/reload/enable/disable units

#### `springboot_auth_deployer` interface

This interface allows the deployment tool to deploy Springboot application files with sensitive authentication information (i.e. files with `springboot_auth_t` SELinux type).

#### `springboot_systemd_deployer` interface

This interface grants permissions to deploy systemd Springboot unit files (and directories).

The scope of actions on the Linux system main systemd directories is limited to deploying (creating/writing) unit files/diretcories with the resulting SELinux type `springboot_unit_file_t`.
Then the deployment tool is allowed to fully manage those files/directories.

#### `springboot_systemd_unit_instance_deployer` interface

This interface should be used when Springboot application services are managed as systemd instances of the `springboot@` template service.
The `springboot_systemd_unit_instance_deployer` interface needs the service instance name as its second argument.

Then the deployment tool is granted permission to create unit files/directories for that service instance.

Usage example:

```selinux
springboot_systemd_unit_instance_deployer(ansible, myapp)
```

Will allow the Ansible domain `ansible_t` to create/start/activate/deactivate the `springboot@myapp.service` unit instance.

### Starting the Springboot application

The Java Springboot application should always and only be started as a
**systemd** service using the`systemctl` command.

The service or target unit files MUST be located in /etc/systemd/system or in
/lib/systemd/system, the file name MUST start with `springboot`.
Directories to tune or override unit behaviour are supported.
Template/instantiated units are supported provided the master file is named
`springboot@.service`.

The script(s) used to start or stop the Springboot application MUST be located in the
/opt/springboot/service/ directory. The /opt/springboot/bin/springboot_service file name
is also supported.

### Running multiple Springboot applications on the same host

#### Without isolation

Nothing special needs to be done.
Care must be taken to name each Springboot apps properly and to properly use systemd/systemctl to manage each one.

#### With isolation between the Springboot apps

TO DO

## Related projects

While having a look at this SELinux policy module for Springboot application, you should probably take a glance at:

* A Puppet module module to deploy Springboot applications: <https://github.com/lhqg/puppet-springboot>
* Ansible roles to deloy Springboot applications: <https://github.com/lhqg/ansible-springboot>
* A SElinux policy module for batches running using Springboot: <https://github.com/lhqg/selinux_springbatch>

## Disclaimer

The code of the this SELinux policy module is provided AS-IS. People and organisation
willing to use it must be fully aware that they are doing so at their own risks and
expenses.

The Author(s) of this SELinux policy module SHALL NOT be held liable nor accountable, in
 any way, of any malfunction or limitation of said module, nor of the resulting damage, of
 any kind, resulting, directly or indirectly, of the usage of this SELinux policy module.

It is strongly advised to always use the last version of the code, to check for the
compatibility of the platform where it is about to be deployed, to compile the module on
the target specific Linux distribution and version where it is intended to be used.

Finally, users should check regularly for updates.
