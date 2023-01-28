#
# === Parameters
#
# [*enable_systemd_target*]
#   Whether the springboot.target systemd unit should be enabled or not
class springboot::core::systemd (
  Boolean $enable_systemd_target,
) {
  #
  ## Dependencies
  #

  Class['springboot::core::packages'] -> Class['springboot::core::systemd']

  #
  ## Resources
  #

  service { 'springboot.target':
    enable   => $enable_systemd_target,
    provider => 'systemd',
  }
}
