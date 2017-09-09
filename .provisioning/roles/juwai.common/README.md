Ansible Role: Common
=========

Configure locale/repo/timezone and install some necessary packages on CentOS servers.

Requirements
------------

Written in Ansible 1.9.*

Role Variables
--------------

Available variables are listed below, along with default values (see `defaults/main.yml`):

### common_lang common_lc_all

Set systemwide `LANG` and `LC_ALL`.

Default is `en_US.UTF-8`.

### timezone

Set systemwide `timezone`.

Default is `Asia/Shanghai`.

### force_update_yum

Force update yum repos and packages.

Default is `no`.

### system_packages

Define a custom list of packages to install.

Default is `[]`(empty list).

Note: this won't override pre-defined `__system_packages`.

### env

Define env to `vagrant` would install webtatic repo.

Default is `vagrant`.

Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
        roles:
         - common

License
-------

MIT / BSD

Author Information
------------------

This role was created in 2015 by [Juwai Limited](http://www.juwai.com).
