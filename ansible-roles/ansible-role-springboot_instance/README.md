ansible-role-springboot_instance
================================

An Ansible role that deploys Springboot an application instance.

> **Disclaimer:**
>
> - The stable versions of the role are tagged. You can find all the available tags with their release notes under Repository/Tags. When you import the role in the requirements.yml file we recommend to use a tagged version of the role.
> - You may find the release notes & the a migration guide for the latest versions in the [release-notes.md](release-notes.md) file.

Requirements
-------------

- The `ansible-role-springboot_foundation` ran successfully,
- The springboot application is being installed as a service (not if `sb_become` is set on no/false),
- The application JAR file must be downloaded previously to `sb_workdir` by the playbook,
- The configuration files should be stored/downloaded to {{ playbook_dir }}/files/conf. Also, they should be templated.
- Java must be installed [ unless it is provided in the jar ],
- Make sure that the `sb_log_dir` resides outside of the springboot appbase.
- Make sure that the `sb_user` that you defined exists on the testing environment.
- This Role requires "root" access to install and manage services, also for setting different rights for files & folders ! To avoid that (in case the remote user doesn't have access as root on the server), one (the user, role consumer) should set `sb_become`=no(or false) !

Role Variables
---------------

- Default variables (from defaults/main.yml):
  - `sb_workdir`: The path where the artifacts are being downloaded on the target machines. Default: "/var/tmp/springboot"
  - `sb_appbase`: The path where the app will reside. Default: "/opt/springboot/`sb_appname`"
  - `sb_appbase_mode`: The dir-mode permission for `sb_appbase`. Default: "0750" (**Please make sure the value is surrounded with quote marks if the value is prefixed with "0" !**)
  - `sb_jar_location`: The destination path where the *JAR application* will reside. Default: "`sb_appbase`/lib"
  - `sb_app_mode`: The dir & files mode permission for the JAR application destination location ("`sb_jar_location`/" & "`sb_jar_location`/`sb_appjarname`"). Default: "0750" (**Please make sure the value is surrounded with quote marks if the value is prefixed with "0" !**)
  - `sb_conf_src`: As the configuration files are stored in the playbook, they should be jinja2 templates in the playbook at this path "{{ playbook_dir }}/files/conf" and set the values for the configuration properties in them. Default value: "`playbook_dir`/files/conf" ("{{ playbook_dir }}/files/conf").
  - `sb_appbase_conf_location`: The destination path of the configuration files. Default: "`sb_appbase`/conf"
  - `sb_conf_mode`: The dir & files mode permission for the `sb_appbase_conf_location` and each copied conf dir & file from `sb_conf_src` to `sb_appbase_conf_location`/. Default: "0750" (**Please make sure the value is surrounded with quote marks if the value is prefixed with "0" !**)
  - `sb_java_extra_args`: Extra arguments when starting the java application. For example: "-Dproperty=value". It is used in the `springboot_rc_service.j2` template file. Default value: "" (See: [Example playbook](#example) & [Using Keystores](#keystore))
  - `sb_enable_service`: Set this on "yes" if you want to let the springboot server to be started at the boot-time (unused if `sb_become` is no/false). Default value: "yes".
  - `sb_log_dir_mode`: The dir mode permission for the log folder. Default: "0750" (**Please make sure the value is surrounded with quote marks if the value is prefixed with "0" !**)
  - `sb_log_symlink`: If set to `true` a symbolic link named `logs` will be created under `sb_appbase` which points to `sb_log_dir`. Default: `no`.
  - `sb_become`: Should the role try to switch the UNIX-user to root to be able to install & manage the springboot application service, and set some ownerships for some directories & files ? If one (the user, role consumer) sets `sb_become` on `no` or `false`, the springboot application cannot be started as a service (the role will skip service implementation), this the application cannot be started at boot time (`sb_enable_service` will have no effect), also the the owership of some files through `sb_*_user` & `sb_*_group` (the group may be set in some situations when the unix-user is in multiple unix-groups and the one selects one of them), **but the application will be started at role deploytime through the direct call of the script `sb_service_script_filename`**. Default value: "yes"
  - `sb_run_dir`: The destination path where the service of the application may store transient files whilethe application runs. Default: "`sb_appbase`/run"
  - `sb_run_dir_mode`: The dir mode permission for the run folder `sb_run_dir` where transient files will reside. Default: "0750" (**Please make sure the value is surrounded with quote marks if the value is prefixed with "0" !**)
  - `sb_java_home`: The path to java. Default value: "/usr".
  - `sb_run_handlers`: Should run `Start Springboot Server` (or `Start Springboot Server (via script)`) and `Cleanup workdir` handlers automatically, or not. Default value: "yes".
  - `sb_cleanup_entire_workdir`: Should remove the entire `sb_workdir` (not only the file `sb_workdir`/`sb_appjarname`), or not. Default value: "no". (**This works only if `sb_run_handlers` is set on "yes" ("true") !**)
  - `sb_bin_mode`: The dir & files mode permission for "`sb_appbase`/bin/" & "`sb_appbase`/bin/`sb_service_script_filename`". Default: "0750" (**Please make sure the value is surrounded with quote marks if the value is prefixed with "0" !**)
  - `sb_extra_files_dest`: The destination location of some extra binary files that may be needed by the JAR application. Default: `sb_jar_location` (See the optional `sb_extra_files_src` variable described below in the section ["Other variables that may optionally be added/changed:"](#optional))
  - `sb_extra_files_mode`: The dir & files modes of the destination folder for extra binary files that may be needed by the aplpication. Default: "0750" (**Please make sure the value is surrounded with quote marks if the value is prefixed with "0" !**)
  - `sb_keystores_mode`: The mode of the folder & files to be copied from `sb_keystores_src` (local project path) to `sb_keystores_dest` (on the remote target servers) in case those are set. Default: "0750" (**Please make sure the value is surrounded with quote marks if the value is prefixed with "0" !**)
  - `sb_prop_logging_path`: Variable to pass the spring boot system property for logging path. It's the equivalent of the application property `logging.file.path`. If you override this variable, make sure to don't put the logs into the `appbase` directory as this is removed at the beginning of the role execution. (**This is used only by the default `springboot_rc_service.j2`**).Default: the value of the variable: `sb_log_dir`
  - `sb_undeploy`: Variable used for in case you want to undeploy the spring boot application. Default value: false
    Remark: Currently only supported on RHEL7 and RHEL8.
  - `sb_remove_extra_files`: Variable used to indicate if you want to remove the extra files, the parameter is only effective in combination with `sb_undeploy`. It can be the case you copied the files to a filelocation other then (or a sub folder of) `sb_appbase`. In that case you can set the variable to `true` and the files within the `sb_extra_files_dest` will be removed, based on the matching files indicated by `sb_extra_files_src`. Default value: `false`
  - `sb_remove_keystores`: Variable used to indicate if you want to remove the keystore, the parameter is only effective in combination with `sb_undeploy`. It can be the case you copied the files to a filelocation other then (or a sub folder of) `sb_appbase`. In that case you can set the variable to `true` and the files within the `sb_keystores_dest` will be removed, based on the matching files indicated by `sb_keystores_src`. Default value: `false`

If you don't want the handlers to be run at the end of the role execution, you should set the variable for the `sb_run_handlers` to false. However, if you want to run the handlers afterwards, the first task that is executed after the role should set the value for this variable to true.

```yaml
  post_tasks:
    - set_fact:
        sb_run_handlers: yes
```

```yaml
---
# Definition of defaults file for ansible-role-springboot_instance

sb_workdir: /var/tmp/springboot
sb_appbase: "/opt/springboot/{{ sb_appname }}"
sb_jar_location: "{{ sb_appbase }}/lib"
sb_conf_src: "{{ playbook_dir }}/files/conf"
sb_appbase_conf_location: "{{ sb_appbase }}/conf"
sb_log_dir: "/var/log/springboot/{{ sb_appname }}"
sb_run_dir: "{{ sb_appbase }}/run"
sb_java_home: "/usr"
sb_run_handlers: yes
sb_cleanup_entire_workdir: no
sb_extra_files_dest: "{{ sb_jar_location }}"
sb_appbase_mode: "0750"

sb_start_at_boot: yes
sb_become: yes
sb_user: springboot
sb_group: springboot

sb_java_extra_args: ""
sb_log_symlink: no
sb_prop_logging_path: "{{ sb_log_dir }}"

# dir&files permissions for "{{ sb_appbase }}/bin/" & "{{ sb_appbase }}/bin/{{ sb_service_script_filename }}":
sb_bin_mode: "0750"

# dir permissions for "{{ sb_appbase }}/run/" used to store transient files
sb_run_dir_mode: "0750"

# dir&files permissions for "{{ sb_jar_location }}/" & "{{ sb_jar_location }}/{{ sb_appjarname }}"
# ( ! one should be sure that the running user have access to this location ! )
sb_app_mode: "0750"

# dir&files permissions for "{{ sb_appbase_conf_location }}/" , "{{ sb_appbase_conf_location }}//each_copied_conf-dir/" & "{{ sb_appbase_conf_location }}//each_copied_conf-dir/each_copied_conf-file":
sb_conf_mode: "0750"

# dir permissions for "{{ sb_log_dir }}/" used to store the running jar log files
sb_log_dir_mode: "0750"

# dir&files permissions for "{{ sb_extra_files_dest }}/" && "{{ sb_extra_files_dest }}/each_copied_extra_file"
sb_extra_files_mode: "0750"

# dir&files permissions for "{{ sb_keystores_dest }}/" && "{{ sb_keystores_dest }}/each_copied_keystore_file"
sb_keystores_mode: "0750"

# settings for undeploy of your springboot application
sb_undeploy: false
sb_remove_extra_files: false
sb_remove_keystores: false


```

- Playbook variables which **MUST** be defined at playbook level:
  - `sb_appname`: The name of the application.
  - `sb_app_version`: Version of the application
  - `sb_appjarname`: The JAR application name

- <a name="optional">Other variables that may optionally be added/changed:</a>
  - `sb_extra_files_src`: The source location of some extra binary files that may be needed by the application. Recommended value: "`playbook_dir`/files/extra".
  - `sb_keystores_src`: The source location of the keystore & cacerts files (should be relative to local playbook project path) . If you need an environment based separation, you'll need to customize this location to include you environment name. Recommended value: "`playbook_dir`/files/keys".
  - `sb_keystores_dest`: The destination location (directory) of the keystore & cacerts files (on the remote target servers). Recommended value: "`sb_appbase`/keys"

> <a name="keystore">**Using keystores (after setting `sb_keystores_src` & `sb_keystores_dest`):**</a><br/>
> Since the variables `sb_keystores_src` & **`sb_keystores_dest`** are referring to folders which may contain any number of keystores-files, but the springboot application will require only one keystore by setting the property `server.ssl.key-store`, one (the user, role consumer) should specify that keystore (otherwise no keystores are used) like this:<br/>
> `sb_java_extra_args: "-Dserver.ssl.key-store=file:{{ sb_keystores_dest }}/{{ sb_appname }}_keystore1.jks -Dserver.ssl.key-store-password={{ my_app_keystore_vault_password_var }}"`<br/>
> Don't forget to set other keystore properties like `server.ssl.key-store-password` or `server.ssl.key-password`.<br/>
> More info: [Configure SSL in Springboot Application](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#howto-configure-ssl)

- Predefined variables that shouldn't be changed:
  - `sb_service_name`: The name of the service (default for RHEL6 is: *springboot-`sb_appname`* ;  for RHEL7 and RHEL8 is: *springboot@`sb_appname`*)

- Variables that are used by the template env file `service-env.j2` which should be defined:
  - `sb_java_home`
  - `sb_log_dir`
  - `sb_appbase_conf_location`
  - `sb_jar_location`
  - `sb_appjarname`

- <a name="example">Example of variable definition at playbook level:</a>

```yaml
---
sb_appname: HelloWorldExample
sb_app_version: 1.0.0
sb_appjarname: "HelloWorldExample-{{ sb_app_version }}.jar"
sb_keystores_src: "{{ playbook_dir }}/files/keys"
sb_keystores_dest: "{{ sb_appbase }}/keys"
sb_java_extra_args: "-Dserver.ssl.key-store=file:{{ sb_keystores_dest }}/{{ sb_appname }}_keystore1.jks -Dserver.ssl.key-store-password={{ my_app_keystore_vault_password_var }}"
sb_cleanup_entire_workdir: yes
```

Example playbook
-----------------

- For *Gitlab* users, a playbook example which uses this role can be found in this [Springboot test playbook project](https://gitlab.ing.net/CDAns/ansible-playbook-springboot-test).
- For *Azure Devops* users, a playbook example which uses this role can be found in this [Springboot test playbook project](https://dev.azure.com/INGCDaaS/IngOne/_git/P02316-ansible-playbook-springboot-test).

Role execution flow
--------------------

At runtime, the role will perform the following actions:

- Attempt to stop the server via an existing systemd service instance. If the service exists, it is stopped and the application files are removed (see: `sb_user`, `sb_log_dir`, `sb_become`, `sb_service_name`)
- If the service does not exist, it is registered as an instance of a systemd service template (for RHEL7 or RHEL8) (see: `sb_start_at_boot`, `sb_become` & `sb_service_name`)
- The application is copied to the target location (see: `sb_appname`, `sb_app_version`, `sb_appjarname`, `sb_appbase`, `sb_jar_location`, `sb_workdir`)
- Copy all the configuration files via template (see: `sb_conf_src` & `sb_appbase_conf_location`)
- Copy extra binary files if they exist (and if `sb_extra_files_src` & `sb_extra_files_dest` are defined and non-empty)
- Copy keystores & certificates if they exist. (*User/Consumer have to add them to the springboot application config !*, see: [Using Keystores](#keystore))
- Start the service via handler (if `sb_run_handlers` is `yes`/`true`)
- Cleanup the working directory via handler (if `sb_run_handlers` is `yes`/`true`)

Dependencies
-------------

- RHEL7 or 8 (might work with any Linux distro, if `sb_become` is set on `no`/`false` => no Linux service will be used)
- Ansible role ansible-role-springboot_foundation
- `ansible` version >= 2.5.0
- `java` JRE or JDK (e.g. java-1.8.0-oracle-1.8.0.191-1jpp.1.el7.x86_64), version depending of your APP (see `sb_java_home`)
- linux (RHEL) packages: `bash`, `procps`
- linux (RHEL) packages: `chkconfig` for *RHEL6* or `systemd` for *RHEL7* and *RHEL8*, if `sb_become` & `sb_run_handlers` are set on `yes`/`true`
- optionally: maybe `filesystem` package (for `/proc/`), or `proc` to exist in mounted filesystems (in case `sb_become` is `no`/`false`, check if the remote user have access on `/proc/` !)

Usage
-----

Via `requirements.yml`:

```yaml
---

- name: ansible-role-springboot_instance
  scm: git
  version: a tag of the role

```
