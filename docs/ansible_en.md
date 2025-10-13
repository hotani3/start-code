# How to Use Ansible Development Tools

## Activating the Ansible Virtual Environment
In start-code, Ansible is installed into a Python virtual environment.  
The Ansible virtual environment is created under the `envs` directory in your home directory, so activate the virtual environment to enable Ansible.

```sh
source ~/envs/ansible-2.18.10-on-python-3.12.12/bin/activate
```

After activation, confirm that the `ansible` command is available.
```sh
ansible --version
```

Here is an example of the version output.
> ansible [core 2.18.10]  
>   config file = None  
>   configured module search path = ['/Users/username/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']  
>   ansible python module location = /Users/username/envs/ansible-2.18.10-on-python-3.12.12/lib/python3.12/site-packages/ansible  
>   ansible collection location = /Users/username/.ansible/collections:/usr/share/ansible/collections  
>   executable location = /Users/username/envs/ansible-2.18.10-on-python-3.12.12/bin/ansible  
>   python version = 3.12.12 (main, Oct 13 2025, 14:14:27) [Clang 15.0.0 (clang-1500.3.9.4)] (/Users/username/envs/ansible-2.18.10-on-python-3.12.12/bin/python3)  
>   jinja version = 3.1.6  
>   libyaml = True

Also, once the virtual environment is activated, Python switches to the version specified when executing `ansible.sh`.
```sh
python -V
```

> Python 3.12.12

## Managing Ansible Collections and Roles
In Ansible, collections and roles—which are equivalent to external libraries—can be managed using the `ansible-galaxy` tool.

However, by default, `ansible-galaxy` installs collections and roles into the `~/.ansible/collections` and `~/.ansible/roles` directories, making it difficult to manage collections and roles by Ansible version or project (custom playbooks and roles).

To manage collections and roles separately for each project, use the `-p` or `--roles-path` option with the `ansible-galaxy` command to install them into the `collections` or `roles` directories within the project directory.
```sh
ansible-galaxy collection install community.kubernetes -p collections
```

```sh
ansible-galaxy role install geerlingguy.apache --roles-path roles
```

If using a `requirements.yml` file that lists all collection and role dependencies, proceed as follows:
```sh
ansible-galaxy collection install -r requirements.yml -p collections
ansible-galaxy role install -r requirements.yml --roles-path roles
```

By creating an `ansible.cfg` file in a project directory with the following content, you can omit the `-p` and `--roles-path` options in `ansible-galaxy`, and the installed collections and roles become available from playbooks.
```ini:ansible.cfg
[defaults]
# Disable cowsay
nocows = True
# Collection search and installation path: ./collections/ansible_collections/namespace/collection_name
collections_path = ./collections
# Role search and installation path: ./roles/namespace.rolename
roles_path = ./roles
```

Thanks to this `ansible.cfg`, even a `requirements.yml` file containing a mix of collections and roles can be installed all at once like so:
```sh
ansible-galaxy install -r requirements.yml
```

## Deactivating the Ansible Virtual Environment
Once you are done using Ansible, deactivate the virtual environment.
```sh
deactivate
```

## Reference Information
- [Ansible best practices: using project-local collections and roles](https://www.jeffgeerling.com/blog/2020/ansible-best-practices-using-project-local-collections-and-roles)
- [Galaxy User Guide](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html)
- [Ansible Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)