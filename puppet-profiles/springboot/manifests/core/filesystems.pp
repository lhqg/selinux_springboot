#
# === Parameters
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
class springboot::core::filesystems (
  Optional[String]  $opt_vg,
  Optional[String]  $srv_vg,
  Optional[String]  $log_vg,
) {
  #
  ## Dependencies
  #

  Package['springboot-selinux'] -> Class['springboot::core::filesystems']

  #
  ## Defaults
  #

  File {
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    seluser => 'system_u',
    selrole => 'object_r',
  }

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
    options => 'defaults,noatime,nodiratime,nodev',
    dump    => '0',
    pass    => '2',
  }

  #
  ## Resources
  #

  unless $opt_vg =~ Undef {
    mountpoint { '/opt/springboot': }
    logical_volume { 'lv_opt_springboot':
      initial_size => '256M',
      volume_group => $opt_vg,
    }
    filesystem { "/dev/${opt_vg}/lv_opt_springboot":
      require => Logical_volume['lv_opt_springboot'],
    }
    mount { '/opt/springboot':
      device  => "/dev/mapper/${opt_vg}-lv_opt_springboot",
      require => [Filesystem["/dev/${opt_vg}/lv_opt_springboot"], Mountpoint['/opt/springboot']],
      before  => File['/opt/springboot'],
    }
  }

  unless $srv_vg =~ Undef {
    mountpoint { '/srv/springboot': }
    logical_volume { 'lv_srv_springboot':
      initial_size => '256M',
      volume_group => $srv_vg,
    }
    filesystem { "/dev/${srv_vg}/lv_srv_springboot":
      require => Logical_volume['lv_srv_springboot'],
    }
    mount { '/srv/springboot':
      device  => "/dev/mapper/${srv_vg}-lv_srv_springboot",
      require => [Filesystem["/dev/${srv_vg}/lv_srv_springboot"], Mountpoint['/srv/springboot']],
      before  => File['/srv/springboot'],
    }

    mountpoint { '/var/lib/springboot': }
    logical_volume { 'lv_varlib_springboot':
      initial_size => '256M',
      volume_group => $srv_vg,
    }
    filesystem { "/dev/${srv_vg}/lv_varlib_springboot":
      require => Logical_volume['lv_varlib_springboot'],
    }
    mount { '/var/lib/springboot':
      device  => "/dev/mapper/${srv_vg}-lv_varlib_springboot",
      require => [Filesystem["/dev/${srv_vg}/lv_varlib_springboot"], Mountpoint['/var/lib/springboot']],
      before  => File['/var/lib/springboot'],
    }

    mountpoint { '/var/tmp/springboot': }
    logical_volume { 'lv_tmp_springboot':
      initial_size => '256M',
      volume_group => $srv_vg,
    }
    filesystem { "/dev/${srv_vg}/lv_tmp_springboot":
      require => Logical_volume['lv_tmp_springboot'],
    }
    mount { '/var/tmp/springboot':
      device  => "/dev/mapper/${srv_vg}-lv_tmp_springboot",
      require => [Filesystem["/dev/${srv_vg}/lv_tmp_springboot"], Mountpoint['/var/tmp/springboot']],
      before  => File['/var/tmp/springboot'],
    }
  }

  unless $log_vg =~ Undef {
    mountpoint { '/var/log/srv/springboot': }
    logical_volume { 'lv_log_springboot':
      initial_size => '512M',
      volume_group => $log_vg,
    }
    filesystem { "/dev/${log_vg}/lv_log_springboot":
      require => Logical_volume['lv_log_springboot'],
    }
    mount { '/var/log/srv/springboot':
      device  => "/dev/mapper/${log_vg}-lv_log_springboot",
      require => [Filesystem["/dev/${log_vg}/lv_log_springboot"], Mountpoint['/var/log/srv/springboot']],
      before  => File['/var/log/srv/springboot'],
    }
  }

  file { '/opt/springboot':
    seltype => 'springboot_bin_t',
  }
  file { ['/srv/springboot', '/var/lib/springboot']:
    seltype => 'springboot_var_t',
  }
  file { '/var/tmp/srv/springboot':
    seltype => 'springboot_tmp_t',
  }
  file { '/var/log/srv/springboot':
    seltype => 'springboot_log_t',
  }
  file { '/etc/springboot':
    seltype => 'etc_t',
  }
}
