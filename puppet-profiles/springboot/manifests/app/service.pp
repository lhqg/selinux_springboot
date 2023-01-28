#
# === Parameters
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
#
# [*jar_name*]
#   Base name of the JAR file (Default value: <application name>.jar)
# [*app_name*]
#   Name of the Springboot application
#
define springboot::app::service (
  Boolean                   $manage_service,
  Boolean                   $service_started,
  Boolean                   $service_enabled,

  Integer                   $startup_timeout_sec,

  Boolean                   $memory_hugepages,
  Integer                   $memory_stacksize_kb,
  Integer                   $memory_max_heapsize_mb,
  Optional[Integer]         $memory_min_heapsize_mb   = undef,

  Optional[String]          $java_args                = undef,
  Optional[String]          $jar_opts                 = undef,
  Optional[String]          $java_extra_opts          = undef,
  Optional[String]          $java_classpath           = undef,
  String                    $jar_name                 = "${name}.jar",

  Optional[String]          $i18n_lang                = undef,

  String                    $app_name                 = $title,
) {
  #
  ## Dependencies
  #

  Springboot::App::Deploy[$title] -> Springboot::App::Service[$title]

  #
  ## Defaults
  #

  File {
    seluser => 'system_u',
    selrole => 'object_r',
    notify  => Exec["Restore SELinux context for springboot application ${title}"],
  }

  #
  ## Resources
  #

  file { "/opt/springboot/${app_name}/env":
    ensure  => file,
    owner   => 'springboot',
    group   => 'springboot',
    mode    => '0400',
    seltype => 'springboot_conf_t',
    content => template('springboot/app/service/env.erb'),
  }

  file { "/etc/systemd/system/springboot@${app_name}.service.d" :
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    seltype => 'springboot_unit_file_t',
    recurse => true,
    purge   => true,
    notify  => Exec["Springboot ${app_name} refresh systemd"],
  }

  if $manage_service {
    service { "springboot@${app_name}":
      enable   => $service_enabled,
      provider => 'systemd',
      require  => [File["/opt/springboot/${app_name}/env",
        "/etc/systemd/system/springboot@${app_name}.service.d"],
      Exec["Springboot ${app_name} refresh systemd"]],
    }

    if $service_started {
      Service["springboot@${app_name}"] {
        ensure => running,
      }
    }
  }
}
