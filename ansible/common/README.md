# Roles
## Install a new role from Ansible Galaxy
```
ansible-galaxy install --roles-path ./roles/ geerlingguy.mysql
```

## Molecule tests
```
python3 -m venv env
source env/bin/activate
python3 -m pip install wheel
python3 -m pip install molecule docker
molecule init scenario -r geerlingguy.mysql -d docker
```
