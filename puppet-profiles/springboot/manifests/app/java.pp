#
# === Parameters
#   OS user that deploys the JAR artifcats and its configuration files
# [*java_version*]
#   Version number of the Java VM (8, 11, 14, 17...)
# [*java_flavour*]
#   Java VM flavour (Oracle, OpenJDK, ...)
#
# [*app_name*]
#   Name of the Springboot application
define springboot::app::java (
  String                    $app_name                            = $name,

  Integer                   $java_version                        = 11,
  Enum['openjdk','oracle']  $java_flavour                        = 'openjdk',
) {
  #
  ## Defaults
  #

  File {
    owner   => 'root',
    group   => 'springboot',
    seluser => 'system_u',
    selrole => 'object_r',
    require => File["/opt/springboot/${app_name}"],
  }

  #
  ## Resources
  #

  case $java_flavour {
    'oracle'  : {
      if $java_version < 11 {
        $pkg_name = "jre1.${java_version}"
      } else {
        $pkg_name = "jre${java_version}"
      }
      $javahome_link_target = "/usr/java/${pkg_name}"

      exec { "Create Oracle Java symlink for springboot ${app_name}":
        path      => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
        command   => "ln -s ${javahome_link_target}*_*-*/ ${javahome_link_target}",
        unless    => "ls ${javahome_link_target}",
        subscribe => Package[$pkg_name],
      }
    }
    'openjdk' : {
      if $java_version < 11 {
        $pkg_name = "java-1.${java_version}.0-openjdk"
        $javahome_link_target = "/etc/alternatives/jre_1.${java_version}.0_openjdk/"
      } else {
        $pkg_name = "java-${java_version}-openjdk"
        $javahome_link_target = "/etc/alternatives/jre_${java_version}_openjdk/"
      }
    }
    default   : { fail("<!>This flavour of Java is not supported: ${java_flavour}<!>") }
  }

  unless defined(Package[$pkg_name]) {
    package { $pkg_name:
      ensure => installed,
    }
  }

  file { "/opt/springboot/${app_name}/java":
    ensure  => link,
    target  => "${javahome_link_target}/bin/java",
    seltype => 'springboot_bin_t',
    force   => true,
    purge   => true,
  }

  file { "/opt/springboot/${app_name}/java_home":
    ensure  => link,
    target  => "${javahome_link_target}/",
    seltype => 'springboot_bin_t',
    force   => true,
    purge   => true,
  }

  file { "/srv/springboot/${app_name}/conf/java":
    ensure  => directory,
    seltype => 'springboot_conf_t',
    require => File["/srv/springboot/${app_name}/conf"],
  }
}
