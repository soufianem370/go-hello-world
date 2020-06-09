Role Name
=========

Deploy a FusionInventory agent and configure it

Requirements
------------

None

Role Variables
--------------

    - fusioninventory_server: The inventory server
    - fusioninventory_cert:   The path to store you self-signed certificate

Dependencies
------------

None

Example Playbook
----------------

    - hosts: all
      roles:
        - role: fusioninventory-agent
      
Execution Command
------------------


License
-------

GPLv2

Author Information
------------------
Copy from Thomas Cottier (thomas.cottier@enalean.com)
Edit By Guillaume Gambs (guillaume.gambs@digimind.com)
