Ansible Role: Supervisor
========================

Install Supervisor on CentOS servers.

Requirements
------------

Written in Ansible 2.0.*

Role Variables
--------------

Available variables are listed below, along with default values (see `defaults/main.yml`):

### config_dir

Directory where supervisord reads configuration files.

Default is `/etc/supervisor.d`.

Dependencies
------------

- juwai.python27

Example Playbook
----------------

    - hosts: servers
      roles:
        - juwai.supervisor

License
-------

MIT

Author Information
------------------

This role was created in 2016 by [Juwai Limited](http://www.juwai.com).