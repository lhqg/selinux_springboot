ansible-role-springboot_foundation
==================================

An Ansible role that deploys LVM and SystemD foundation for Springboot applications to be deployed using the ansible-role-springboot role.

> **Disclaimer:**
>
> - The stable versions of the role are tagged. You can find all the available tags with their release notes under Repository/Tags. When you import the role in the requirements.yml file we recommend to use a tagged version of the role.
> - You may find the release notes & the a migration guide for the latest versions in the [release-notes.md](release-notes.md) file.

Requirements
------------

- The Springboot application services will beÒ handled as instances of a SystemD template service (not if `sb_become` is set on no/false).

- This Role requires "root" access to install and manage services, also for setting different rights for files & folders !
To avoid that (in case the remote user doesn't have access as root on the server), one (the user, role consumer) should set `sb_become`=no(or false), and to be sure that the remote user is set to `springboot` !

Role Variables
--------------

- Default variables (from defaults/main.yml):

  - `sb_user_id`     : The UID for the `springboot` OS user created by this role. Default value: 5000
  - `sb_group_id`    : The GID for the `springboot` OS group created bu thys role. Default value: 5000

  - `sb_become`   : Should the role try to switch the unix-user to root to be able to create user, group, LVM structures, to install & manage the Springboot application service, and set some ownerships for some directories & files ?

- Playbook variables which **MAY** be changed at playbook level:
  - `sb_dedicated_lv_opt` : yes/no whether the foundation role should create dedicated LV/FS for Springboot root /opt/springboot. Default value: yes
  - `sb_dedicated_vg_opt` : the name of the LVM volume groupe on which the foundation role will build /opt/springboot. Default value: none
  - `sb_dedicated_lv_srv` : yes/no whether the foundation role should create dedicated LV/FS for Springboot working root /srv/springboot. Default value: yes
  - `sb_dedicated_vg_srv` : the name of the LVM volume groupe on which the foundation role will build /srv/springboot. Default value: none
  - `sb_dedicated_lv_log` : yes/no whether the foundation role should create dedicated LV/FS for Springboot log root /var/log/springboot. Default value: yes
  - `sb_dedicated_vg_log` : the name of the LVM volume groupe on which the foundation role will build /var/log/springboot. Default value: none

Role execution flow
-------------------

At runtime, the role will perform the following actions:

- Create the Springboot LVM objects (if applicable):
  - Build the springbootVG volume group on the dedicated disk device
  - Build the logical volume and XFS filesystem for the Springboot root installation /opt/springboot
  - Build the logical volume and XFS filesystem for the Springboot logs root directory /var/log/springboot
  - Build the logical volume and XFS filesystem for the Springboot tmp/cache/work root directory /srv/springboot
- Create the Springboot root installation and logs root directories
- Create the Springboot SystemD template/instanciated service unit

Dependencies
------------

- RHEL 7 or 8 (might work with any Linux distro, if `sb_become` is set on `no`/`false` => no Linux service will be used)
- `ansible` version >= 2.5.0
- linux (RHEL) packages: `bash`, `procps`, `selinux-policy-devel`
- linux (RHEL) packages: `systemd` for *RHEL7* and *RHEL8*, if `sb_become`

Usage
-----

Via `requirements.yml`:

```yaml
---

- name: ansible-role-springboot_foundation
  src: https://github.com/hubertqc/selinux_springboot/
  scm: git
  version: a tag of the role

```
