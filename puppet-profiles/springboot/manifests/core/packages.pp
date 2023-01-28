#
class springboot::core::packages {
  #
  ## Defaults
  #

  Package {
    ensure => installed,
  }

  #
  ## Resources
  # 

  package { ['springboot-selinux', 'springboot-selinux-devel', 'springboot-systemd']: }
}
