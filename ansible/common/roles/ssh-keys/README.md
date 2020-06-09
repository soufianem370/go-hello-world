# Description
This role add SSH keys to root user on servers.
You can use the `raw_copy` tag to use Ansible raw module if some hosts failed to use the `authorized_key` module.

**WARNING**: the raw module doesn't prevent duplicate keys.

# Run
See: https://docs.ansible.com/ansible/2.5/user_guide/playbooks_reuse_roles.html#using-roles
