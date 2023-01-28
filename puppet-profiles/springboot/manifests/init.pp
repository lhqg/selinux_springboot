# == Class: springboot
#
# The ::springboot class installs the basic OS structure to host one or many Springboot applications
# 
# === Parameters
# [*springboot_uid*]
#   UID number of the main springboot OS user
#
# [*springboot_gid*]
#   GID number of the main springboot OS group
#
# [*opt_vg*]
#   Name of the volume group where to build the top level FS /opt/springboot
#   Default value undef/nil: no dedicated FS created.
#
# [*srv_vg*]
#   Name of the volume group where to build the top level FS /srv/springboot and /var/lib/springboot
#   Default value undef/nil: no dedicated FS created.
#
# [*log_vg*]
#   Name of the volume group where to build the top level FS /var/log/springboot
#   Default value undef/nil: no dedicated FS created.
#
# [*allow_springboot_connectto_http*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_connectto_self*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_connectto_ldap*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_connectto_smtp*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_connectto_oracle*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_connectto_mysql*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_connectto_pgsql*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_connectto_redis*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_connectto_couchdb*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_connectto_mongodb*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_dynamic_libs*]
#   Boolean to control SELinux boolean
#
# [*allow_springboot_purge_logs*]
#   Boolean to control SELinux boolean
#
# [*allow_webadm_read_springboot_files*]
#   Boolean to control SELinux boolean
#
# [*allow_sysadm_write_springboot_files*]
#   Boolean to control SELinux boolean
#
# [*allow_sysadm_manage_springboot_auth_files*]
#   Boolean to control SELinux boolean
#
# [*enable_systemd_target*]
#   Whether the springboot.target systemd unit should be enabled or not
#
#
# === Authors
#
# Hubert Quarantel-Colombani <hubert@quarantel.name>
#
# === Copyright
#
# Copyright 2023 Hubert Quarantel-Colombani, unless otherwise noted.
#
class springboot (
  Integer                 $springboot_uid,
  Integer                 $springboot_gid,

  Optional[String]        $opt_vg,
  Optional[String]        $srv_vg,
  Optional[String]        $log_vg,

  Boolean                 $allow_springboot_connectto_http,
  Boolean                 $allow_springboot_connectto_self,
  Boolean                 $allow_springboot_connectto_ldap,
  Boolean                 $allow_springboot_connectto_smtp,
  Boolean                 $allow_springboot_connectto_oracle,
  Boolean                 $allow_springboot_connectto_mysql,
  Boolean                 $allow_springboot_connectto_pgsql,
  Boolean                 $allow_springboot_connectto_redis,
  Boolean                 $allow_springboot_connectto_couchdb,
  Boolean                 $allow_springboot_connectto_mongodb,
  Boolean                 $allow_springboot_dynamic_libs,
  Boolean                 $allow_springboot_purge_logs,
  Boolean                 $allow_webadm_read_springboot_files,
  Boolean                 $allow_sysadm_write_springboot_files,
  Boolean                 $allow_sysadm_manage_springboot_auth_files,

  Boolean                 $enable_systemd_target,
) {
  #
  ## Resources: assemble core classes
  #

  class { 'springboot::core::usersgroups':
    springboot_uid => $springboot_uid,
    springboot_gid => $springboot_gid,
  }
  class { 'springboot::core::packages': }
  class { 'springboot::core::filesystems':
    opt_vg => $opt_vg,
    srv_vg => $srv_vg,
    log_vg => $srv_vg,
  }
  class { 'springboot::core::selinux':
    allow_springboot_connectto_http           => $allow_springboot_connectto_http,
    allow_springboot_connectto_self           => $allow_springboot_connectto_self,
    allow_springboot_connectto_ldap           => $allow_springboot_connectto_ldap,
    allow_springboot_connectto_smtp           => $allow_springboot_connectto_smtp,
    allow_springboot_connectto_oracle         => $allow_springboot_connectto_oracle,
    allow_springboot_connectto_mysql          => $allow_springboot_connectto_mysql,
    allow_springboot_connectto_pgsql          => $allow_springboot_connectto_pgsql,
    allow_springboot_connectto_redis          => $allow_springboot_connectto_redis,
    allow_springboot_connectto_couchdb        => $allow_springboot_connectto_couchdb,
    allow_springboot_connectto_mongodb        => $allow_springboot_connectto_mongodb,
    allow_springboot_dynamic_libs             => $allow_springboot_dynamic_libs,
    allow_springboot_purge_logs               => $allow_springboot_purge_logs,
    allow_webadm_read_springboot_files        => $allow_webadm_read_springboot_files,
    allow_sysadm_write_springboot_files       => $allow_sysadm_write_springboot_files,
    allow_sysadm_manage_springboot_auth_files => $allow_sysadm_manage_springboot_auth_files,
  }
  class { 'springboot::core::systemd':
    enable_systemd_target => $enable_systemd_target,
  }
}
