#
# === Parameters
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
class springboot::core::selinux (
  Boolean $allow_springboot_connectto_http,
  Boolean $allow_springboot_connectto_self,
  Boolean $allow_springboot_connectto_ldap,
  Boolean $allow_springboot_connectto_smtp,
  Boolean $allow_springboot_connectto_oracle,
  Boolean $allow_springboot_connectto_mysql,
  Boolean $allow_springboot_connectto_pgsql,
  Boolean $allow_springboot_connectto_redis,
  Boolean $allow_springboot_connectto_couchdb,
  Boolean $allow_springboot_connectto_mongodb,
  Boolean $allow_springboot_dynamic_libs,
  Boolean $allow_springboot_purge_logs,
  Boolean $allow_webadm_read_springboot_files,
  Boolean $allow_sysadm_write_springboot_files,
  Boolean $allow_sysadm_manage_springboot_auth_files,
) {
  #
  ## Dependencies
  #

  Class['springboot::core::packages'] -> Class['springboot::core::selinux']

  #
  ## Defaults
  #

  Selinux::Boolean {
    persistent => true,
  }

  #
  ## Resources
  #

  selinux::boolean { 'allow_springboot_connectto_http':
    ensure => $allow_springboot_connectto_http,
  }
  selinux::boolean { 'allow_springboot_connectto_self':
    ensure => $allow_springboot_connectto_self,
  }
  selinux::boolean { 'allow_springboot_connectto_ldap':
    ensure => $allow_springboot_connectto_ldap,
  }
  selinux::boolean { 'allow_springboot_connectto_smtp':
    ensure => $allow_springboot_connectto_smtp,
  }
  selinux::boolean { 'allow_springboot_connectto_oracle':
    ensure => $allow_springboot_connectto_oracle,
  }
  selinux::boolean { 'allow_springboot_connectto_mysql':
    ensure => $allow_springboot_connectto_mysql,
  }
  selinux::boolean { 'allow_springboot_connectto_pgsql':
    ensure => $allow_springboot_connectto_pgsql,
  }
  selinux::boolean { 'allow_springboot_connectto_redis':
    ensure => $allow_springboot_connectto_redis,
  }
  selinux::boolean { 'allow_springboot_connectto_couchdb':
    ensure => $allow_springboot_connectto_couchdb,
  }
  selinux::boolean { 'allow_springboot_connectto_mongodb':
    ensure => $allow_springboot_connectto_mongodb,
  }
  selinux::boolean { 'allow_springboot_dynamic_libs':
    ensure => $allow_springboot_dynamic_libs,
  }
  selinux::boolean { 'allow_springboot_purge_logs':
    ensure => $allow_springboot_purge_logs,
  }
  selinux::boolean { 'allow_webadm_read_springboot_files':
    ensure => $allow_webadm_read_springboot_files,
  }
  selinux::boolean { 'allow_sysadm_write_springboot_files':
    ensure => $allow_sysadm_write_springboot_files,
  }
  selinux::boolean { 'allow_sysadm_manage_springboot_auth_files':
    ensure => $allow_sysadm_manage_springboot_auth_files,
  }

  exec { 'Restore SELinux fcontexts on Springboot FS':
    path        => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    refreshonly => true,
    command     => 'restorecon -RFi /opt/springboot /etc/springboot /srv/springboot /var/{lib,tmp,log,run}/springboot',
  }
}
