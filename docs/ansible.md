# Ansible

## Ansible 仮想環境の活性化
start-codeでは、AnsibleをPython仮想環境にインストールしています。  
Ansibleの仮想環境は、ホームディレクトリの`envs`ディレクトリ以下に作成されているので、Ansibleが使えるように仮想環境の活性化を行います。

```sh
source ~/envs/ansible-2.17.11-on-python-3.12.8/bin/activate
```

活性化後、`ansible`コマンドが使えることを確認します。
```sh
ansible --version
```

バージョンの表示例です。
> ansible [core 2.17.11]  
>   config file = None  
>   configured module search path = ['/Users/username/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']  
>   ansible python module location = /Users/username/envs/ansible-2.17.11/lib/python3.12/site-packages/ansible  
>   ansible collection location = /Users/username/.ansible/collections:/usr/share/ansible/collections  
>   executable location = /Users/username/envs/ansible-2.17.11/bin/ansible  
>   python version = 3.12.8 (main, Jan 13 2025, 12:25:22) [Clang 14.0.3 (clang-1403.0.22.14.1)] (/Users/username/envs/ansible-2.17.11/bin/python3)  
>   jinja version = 3.1.6  
>   libyaml = True

なお、仮想環境を活性化すると、Pythonも`ansible.sh`実行時に指定したPython実行環境のバージョンに切り替わっています。
```sh
python -V
```

> Python 3.12.8

## Ansible コレクション・ロール管理
Ansibleで外部ライブラリに相当するコレクションとロールは、`ansible-galaxy`ツールで管理可能です。

しかし、`ansible-galaxy`はデフォルトだと、`~/.ansible/collections`ディレクトリにコレクション・ロールをインストールするため、Ansibleのバージョンやプロジェクト（自作プレイブック・ロール）単位でのコレクション・ロール管理ができません。

プロジェクトごとに個別でコレクション・ロール管理を行うには、`ansible-galaxy`コマンドで`-p`オプションを指定して、プロジェクトディレクトリ内の`collections`ディレクトリにコレクション・ロールをインストールするようにします。
```sh
ansible-galaxy collection install community.kubernetes -p collections
```

コレクション・ロールの依存関係をすべて記載した`requirements.yml`を使う場合は、次のようになります。
```sh
ansible-galaxy install -r requirements.yml -p collections
```

## Ansible 仮想環境の非活性化
Ansibleを使い終わったら、仮想環境を非活性化してください。
```sh
deactivate
```
