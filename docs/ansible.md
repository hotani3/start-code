# Ansible 開発ツール使用方法

## Ansible 仮想環境の活性化
start-codeでは、AnsibleをPython仮想環境にインストールしています。  
Ansibleの仮想環境は、ホームディレクトリの`envs`ディレクトリ以下に作成されているので、Ansibleが使えるように仮想環境の活性化を行います。

```sh
source ~/envs/ansible-2.17.11-on-python-3.12.10/bin/activate
```

活性化後、`ansible`コマンドが使えることを確認します。
```sh
ansible --version
```

バージョンの表示例です。
> ansible [core 2.17.11]  
>   config file = None  
>   configured module search path = ['/Users/username/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']  
>   ansible python module location = /Users/username/envs/ansible-2.17.11-on-python-3.12.10/lib/python3.12/site-packages/ansible  
>   ansible collection location = /Users/username/.ansible/collections:/usr/share/ansible/collections  
>   executable location = /Users/username/envs/ansible-2.17.11-on-python-3.12.10/bin/ansible  
>   python version = 3.12.10 (main, May  5 2025, 15:25:53) [Clang 14.0.3 (clang-1403.0.22.14.1)] (/Users/username/envs/ansible-2.17.11-on-python-3.12.10/bin/python3)  
>   jinja version = 3.1.6  
>   libyaml = True

なお、仮想環境を活性化すると、Pythonも`ansible.sh`実行時に指定したPython実行環境のバージョンに切り替わっています。
```sh
python -V
```

> Python 3.12.10

## Ansible コレクション・ロール管理
Ansibleで外部ライブラリに相当するコレクションとロールは、`ansible-galaxy`ツールで管理可能です。

しかし、`ansible-galaxy`はデフォルトだと、`~/.ansible/collections`と`~/.ansible/roles`ディレクトリにコレクション・ロールをインストールするため、Ansibleのバージョンやプロジェクト（自作プレイブック・ロール）単位でのコレクション・ロール管理ができません。

プロジェクトごとに個別でコレクション・ロール管理を行うには、`ansible-galaxy`コマンドで`-p`や`--roles-path`オプションを指定して、プロジェクトディレクトリ内の`collections`や`roles`ディレクトリにコレクション・ロールをインストールするようにします。
```sh
ansible-galaxy collection install community.kubernetes -p collections
```

```sh
ansible-galaxy role install geerlingguy.apache --roles-path roles
```

コレクション・ロールの依存関係をすべて記載した`requirements.yml`を使う場合は、次のようになります。
```sh
ansible-galaxy collection install -r requirements.yml -p collections
ansible-galaxy role install -r requirements.yml --roles-path roles
```

プロジェクトディレクトリに以下の内容の`ansible.cfg`を作成すると、`ansible-galaxy`での`-p`や`--roles-path`が省略でき、インストールしたコレクション・ロールがプレイブックから使用可能になります。
```ini:ansible.cfg
[defaults]
# cowsayを無効化
nocows = True
# コレクションの検索・インストール先: ./collections/ansible_collections/namespace/collection_name
collections_path = ./collections
# ロールの検索・インストール先: ./roles/namespace.rolename
roles_path = ./roles
```

この`ansible.cfg`により、コレクションとロールが混在した`requirements.yml`でも、次のように一度にまとめてインストールできるようになります。
```sh
ansible-galaxy install -r requirements.yml
```

## Ansible 仮想環境の非活性化
Ansibleを使い終わったら、仮想環境を非活性化してください。
```sh
deactivate
```

## 参考情報
 - [Ansible best practices: using project-local collections and roles](https://www.jeffgeerling.com/blog/2020/ansible-best-practices-using-project-local-collections-and-roles)
 - [Galaxy User Guide](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html)
 - [Ansible Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)