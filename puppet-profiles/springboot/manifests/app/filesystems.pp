#
# === Parameters
# [*dedicated_fs_log_vg*]
#   Name of the the LVM volume group to build the log FS for that Springboot app
# [*dedicated_fs_srv_vg*]
#   Name of the the LVM volume group to build the srv/var FS for that Springboot app
# [*dedicated_fs_opt_vg*]
#   Name of the the LVM volume group to build the opt FS for that Springboot app
# [*dedicated_fs_initial_log_size_mb*]
#   Initial size of the log FS for that Springboot app
# [*dedicated_fs_initial_srv_size_mb*]
#   Initial size of the srv/var FS for that Springboot app
# [*dedicated_fs_initial_opt_size_mb*]
#   Initial size of the opt FS for that Springboot app
#
# [*app_name*]
#   Name of the Springboot application
#
define springboot::app::filesystems (
  Integer           $dedicated_fs_initial_log_size_mb,
  Integer           $dedicated_fs_initial_srv_size_mb,
  Integer           $dedicated_fs_initial_opt_size_mb,

  Optional[String]  $dedicated_fs_log_vg  = undef,
  Optional[String]  $dedicated_fs_srv_vg  = undef,
  Optional[String]  $dedicated_fs_opt_vg  = undef,

  String            $app_name             = $title,
) {
  #
  ## Data validation
  #

  if ( $dedicated_fs_initial_log_size_mb * $dedicated_fs_initial_srv_size_mb * $dedicated_fs_initial_opt_size_mb ) == 0 {
    fail('`dedicated_fs_initial_log_size_mb`, `dedicated_fs_initial_srv_size_mb` and `dedicated_fs_initial_opt_size_mb` cannot be zero.')
  }

  #
  ## Dependencies
  #

  Class['springboot'] -> Springboot::App::Filesystems[$title]

  #
  ## Defaults
  #

  Logical_volume {
    ensure => present,
  }

  Filesystem {
    ensure  => present,
    fs_type => 'xfs',
  }

  Mountpoint {
    ensure => present,
  }

  Mount {
    ensure  => mounted,
    atboot  => true,
    fstype  => 'xfs',
    options => 'defaults,noatime,nodiratime,nosuid,nodev',
    dump    => '0',
    pass    => '2',
  }

  #
  ## Resources
  #

  unless $dedicated_fs_opt_vg =~ Undef {
    mountpoint { "/opt/springboot/${app_name}":
      require => File['/opt/springboot'],
    }
    logical_volume { "lv_opt_springboot_${app_name}":
      initial_size => "${dedicated_fs_initial_opt_size_mb}M",
      volume_group => $dedicated_fs_opt_vg,
    }
    filesystem { "/dev/${dedicated_fs_opt_vg}/lv_opt_springboot_${app_name}":
      require => Logical_volume["lv_opt_springboot_${app_name}"],
    }
    mount { "/opt/springboot/${app_name}":
      device  => "/dev/mapper/${dedicated_fs_opt_vg}-lv_opt_springboot_${app_name}",
      require => [Filesystem["/dev/${dedicated_fs_opt_vg}/lv_opt_springboot_${app_name}"], Mountpoint["/opt/springboot/${app_name}"]],
      before  => File["/opt/springboot/${app_name}"],
    }
  }

  unless $dedicated_fs_srv_vg =~ Undef {
    mountpoint { "/srv/springboot/${app_name}":
      require => File['/srv/springboot'];
    }
    logical_volume { "lv_srv_springboot_${app_name}":
      initial_size => "${dedicated_fs_initial_srv_size_mb}M",
      volume_group => $dedicated_fs_srv_vg,
    }
    filesystem { "/dev/${dedicated_fs_srv_vg}/lv_srv_springboot_${app_name}":
      require => Logical_volume["lv_srv_springboot_${app_name}"],
    }
    mount { "/srv/springboot/${app_name}":
      device  => "/dev/mapper/${dedicated_fs_srv_vg}-lv_srv_springboot_${app_name}",
      require => [Filesystem["/dev/${dedicated_fs_srv_vg}/lv_srv_springboot_${app_name}"], Mountpoint["/srv/springboot/${app_name}"]],
      before  => File["/srv/springboot/${app_name}"],
    }
  }

  unless $dedicated_fs_log_vg =~ Undef {
    mountpoint { "/var/log/springboot/${app_name}":
      require => File['/var/log/springboot'];
    }
    logical_volume { "lv_log_springboot_${app_name}":
      initial_size => "${dedicated_fs_initial_log_size_mb}M",
      volume_group => $dedicated_fs_log_vg,
    }
    filesystem { "/dev/${dedicated_fs_log_vg}/lv_log_springboot_${app_name}":
      require => Logical_volume["lv_log_springboot_${app_name}"],
    }
    mount { "/var/log/srv/springboot/${app_name}":
      device  => "/dev/mapper/${dedicated_fs_log_vg}-lv_log_springboot_${app_name}",
      require => [Filesystem["/dev/${dedicated_fs_log_vg}/lv_log_springboot_${app_name}"],
      Mountpoint["/var/log/srv/springboot/${app_name}"]],
      before  => File["/var/log/srv/springboot/${app_name}"],
    }
  }
}
