#
# === Parameters
# [*springboot_uid*]
#   UID number of the main springboot OS user
#
# [*springboot_gid*]
#   GID number of the main springboot OS group
#
class springboot::core::usersgroups (
  Integer $springboot_uid,
  Integer $springboot_gid,
) {
  #
  ## Resources
  #
  group { 'springboot':
    ensure => present,
    gid    => $springboot_gid,
  }

  user { 'springboot':
    ensure         => present,
    uid            => $springboot_uid,
    gid            => 'springboot',
    shell          => '/sbin/nologin',
    home           => '/home/springboot',
    password       => '!',
    managehome     => true,
    purge_ssh_keys => true,
    require        => Group['springboot'],
  }
}
