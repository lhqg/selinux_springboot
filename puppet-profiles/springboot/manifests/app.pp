#
# === Parameters
# [*listen_port*]
#   TCP port the Springboot app listens on
# [*deployment_user*]
#   OS user that deploys the JAR artifcats and its configuration files
# [*java_version*]
#   Version number of the Java VM (8, 11, 14, 17...)
# [*java_flavour*]
#   Java VM flavour (Oracle, OpenJDK, ...)
# [*memory_max_heapsize_mb*]
#   Max heap size for the Java VM
# [*memory_min_heapsize_mb*]
#   Min heap size for the Java VM
# [*memory_stacksize_kb*]
#   Stack size for the Java VM
# [*memory_hugepages*]
#   Whether the Linux Huge pages should be sued by the Java VM
# [*java_args*]
#   Arguments for the Java VM
# [*jar_opts*]
#   Arguments/options for the Springboot app JAR
# [*java_extra_opts*]
#   Extra Java arguments
# [*java_classpath*]
#   Class path for the Java VM
# [*manage_service*]
#   Whether Puppet should manage the systemd service for that Springboot app
# [*service_started*]
#   Whether Puppet should care is the systemd service for that Springboot app is running or not
# [*service_enabled*]
#   Whether Puppet should enable the systemd service for that Springboot app
# [*startup_timeout_sec*]
#   Timemout for the Springboot app to be considered prematurely dead during startup
# [*i18n_lang*]
#   i18n specification for the Java VM env
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
# [*jar_distribution_uri*]
#   URI where the JAR file can be downloaded from
# [*jar_name*]
#   Base name of the JAR file (Default value: <application name>.jar)
# [*restart_app_upon_jar_change*]
#   Whether Puppet should restart the application service
#   each time the JAR file changes
# [*app_name*]
#   Name of the Springboot application
#
define springboot::app (
  Stdlib::Port                  $listen_port,

  Oprional[Stdlib::Filesource]  $jar_distribution_uri             = undef,
  String                        $jar_name                         = "${name}.jar",

  Optional[String]              $deployment_user                  = undef,

  Integer                       $java_version                     = 11,
  Enum['openjdk','oracle']      $java_flavour                     = 'openjdk',

  Integer                       $memory_max_heapsize_mb           = 256,
  Optional[Integer]             $memory_min_heapsize_mb           = undef,
  Integer                       $memory_stacksize_kb              = 512,
  Boolean                       $memory_hugepages                 = false,
  Optional[String]              $java_args                        = undef,
  Optional[String]              $jar_opts                         = undef,
  Optional[String]              $java_extra_opts                  = undef,
  Optional[String]              $java_classpath                   = undef,
  Boolean                       $manage_service                   = true,
  Boolean                       $service_started                  = false,
  Boolean                       $service_enabled                  = false,
  Integer[5,300]                $startup_timeout_sec              = 10,
  Optional[String]              $i18n_lang                        = undef,
  Boolean                       $restart_app_upon_jar_change      = false,

  Optional[String]              $dedicated_fs_log_vg              = undef,
  Optional[String]              $dedicated_fs_srv_vg              = undef,
  Optional[String]              $dedicated_fs_opt_vg              = undef,
  Integer                       $dedicated_fs_initial_log_size_mb = 1024,
  Integer                       $dedicated_fs_initial_srv_size_mb = 1024,
  Integer                       $dedicated_fs_initial_opt_size_mb = 256,

  String                        $app_name                         = $title,
) {
  #
  ## Dependencies
  #
  Class['springboot'] -> Springboot::App[$title]

  #
  ## Defaults
  #

  File {
    ensure  => file,
    owner   => 'root',
    group   => 'springboot',
    seluser => 'system_u',
    selrole => 'object_r',
  }

  Exec {
    refreshonly => true,
    path        => ['/bin', '/sbin', '/usr/sbin', '/usr/bin'],
  }

  #
  ## Resources
  #

  $svc_app_name = regsubst($app_name, '[-.]', '_', 'G')

  springboot::app::java { $svc_app_name:
    java_flavour => $java_flavour,
    java_version => $java_version,
  }

  springboot::app::filesystems { $svc_app_name:
    dedicated_fs_log_vg              => $dedicated_fs_log_vg,
    dedicated_fs_srv_vg              => $dedicated_fs_srv_vg,
    dedicated_fs_opt_vg              => $dedicated_fs_opt_vg,
    dedicated_fs_initial_log_size_mb => $dedicated_fs_initial_log_size_mb,
    dedicated_fs_initial_srv_size_mb => $dedicated_fs_initial_srv_size_mb,
    dedicated_fs_initial_opt_size_mb => $dedicated_fs_initial_opt_size_mb,
  }

  springboot::app::service { $svc_app_name:
    manage_service         => $manage_service,
    service_started        => $service_started,
    service_enabled        => $service_enabled,
    memory_max_heapsize_mb => $memory_max_heapsize_mb,
    memory_min_heapsize_mb => $memory_min_heapsize_mb,
    memory_stacksize_kb    => $memory_stacksize_kb,
    memory_hugepages       => $memory_hugepages,
    java_args              => $java_args,
    jar_opts               => $jar_opts,
    jar_name               => $jar_name,
    java_extra_opts        => $java_extra_opts,
    java_classpath         => $java_classpath,
    i18n_lang              => $i18n_lang,
  }

  springboot::app::deploy { $svc_app_name:
    deployment_user             => $deployment_user,
    listen_port                 => $listen_port,
    jar_distribution_uri        => $jar_distribution_uri,
    jar_name                    => $jar_name,
    restart_app_upon_jar_change => $restart_app_upon_jar_change,
  }

  exec { "Restore SELinux context for springboot ${svc_app_name}":
    command => "restorecon -RFi /{srv,opt}/springboot/${svc_app_name} /var/{log,lib,run,tmp}/springboot/${svc_app_name}",
  }

  exec { "Springboot ${svc_app_name} refresh systemd":
    command => 'systemctl daemon-reload',
  }
}
