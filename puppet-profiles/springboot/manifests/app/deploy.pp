#
# === Parameters
# [*listen_port*]
#   TCP port the Springboot app listens on
# [*deployment_user*]
#   OS user that deploys the JAR artifcats and its configuration files
#
# [*jar_distribution_uri*]
#   URI where the JAR file can be downloaded from
# [*jar_name*]
#   Base name of the JAR file (Default value: <application name>.jar)
# [*restart_app_upon_jar_change*]
#   Whether Puppet should restart the application service
#   each time the JAR file changes
# [*app_name*]
#   Name of the Springboot application
define springboot::app::deploy (
  Stdlib::Port                  $listen_port,

  Boolean                       $restart_app_upon_jar_change,

  Optional[Stdlib::Filesource]  $jar_distribution_uri = undef,
  String                        $jar_name             = "${name}.jar",

  Optional[String]              $deployment_user      = undef,

  String                        $app_name             = $title,
) {
  #
  ## Dependencies
  #

  Springboot::App::Filesystems[$title] -> Springboot::App::Deploy[$title]

  #
  ## Defaults
  #

  File {
    ensure  => directory,
    owner   => 'springboot',
    group   => 'springboot',
    mode    => '2750',
    seluser => 'system_u',
    selrole => 'object_r',
    purge   => false,
    recurse => false,
    force   => false,
    backup  => false,
    notify  => Exec["Restore SELinux context for springboot ${title}"],
  }

  if $deployment_user =~ Undef {
    $final_deployment_user = 'springboot'
  } else {
    $final_deployment_user = $deployment_user
  }

  #
  ## Resources
  #

  ## Daemon directory structure

  file { "/opt/springboot/${app_name}":
    owner   => 'root',
    mode    => '0640',
    recurse => true,
    purge   => true,
    seltype => 'springboot_bin_t',
    require => File['/opt/springboot'],
  }
  file { "/opt/springboot/${app_name}/lib":
    owner   => $deployment_user,
    mode    => '0640',
    seltype => 'springboot_lib_t',
    require => File["/opt/springboot/${app_name}"],
  }
  file { "/opt/springboot/${app_name}/bin":
    owner   => $deployment_user,
    mode    => '0640',
    seltype => 'springboot_bin_t',
    require => File["/opt/springboot/${app_name}"],
  }
  file { "/srv/springboot/${app_name}/conf":
    owner   => $deployment_user,
    mode    => '2754',
    seltype => 'springboot_conf_t',
    require => File["/srv/springboot/${app_name}"],
  }
  file { "/srv/springboot/${app_name}/keys":
    owner   => $deployment_user,
    mode    => '2750',
    seltype => 'springboot_auth_t',
    require => File["/srv/springboot/${app_name}"],
  }

  file { "/srv/springboot/${app_name}":
    seltype => 'springboot_var_t',
    require => File['/srv/springboot'],
    mode    => '3755',
  }
  file { ["/srv/springboot/${app_name}/cache", "/srv/springboot/${app_name}/run", "/srv/springboot/${app_name}/work"]:
    mode    => '0750',
    seltype => 'springboot_run_t',
    require => File["/srv/springboot/${app_name}"],
  }
  file { "/srv/springboot/${app_name}/dynlib":
    owner   => $deployment_user,
    mode    => '2754',
    seltype => 'springboot_dynlib_t',
    require => File["/srv/springboot/${app_name}"],
  }

  file { "/var/log/springboot/${app_name}":
    seltype => 'springboot_log_t',
    require => File['/var/log/springboot'],
    mode    => '2755',
  }

  selinux::port { "Springboot_${listen_port}":
    ensure   => present,
    seltype  => 'springboot_port_t',
    protocol => 'tcp',
    port     => $listen_port,
  }

  unless $jar_distribution_uri =~ Undef {
    file { "/opt/springboot/${app_name}/lib/${jar_name}":
      owner   => 'springboot',
      mode    => '0440',
      seltype => 'springboot_lib_t',
      source  => $jar_distribution_uri,
      require => File["/opt/springboot/${app_name}/lib"],
    }

    if $restart_app_upon_jar_change {
      Service <| title == "springboot@${app_name}" |> {
        subscribe => File["/opt/springboot/${app_name}/lib/${jar_name}"],
      }
    }
  }
}
