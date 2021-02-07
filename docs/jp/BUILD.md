## Serene Linuxをビルドする
ビルドは実機のFedora Linuxを利用する方法とDocker上でビルドする方法があります。

Dockerでビルドする方法は[この手順](DOCKER.md)を参照してください。

実機でビルドする場合は、必ずOSがSerene Linux（Beta８F以降）か

 **SELinuxを無効化した**Fedora LinuxやCentOS、

または**dnfをインストールした**Arch Linuxでなければなりません。

以下では実機でビルドする方法を解説します。



### 準備

ソースコードを取得します。

```bash
git clone https://github.com/FascodeNet/LFBS.git
cd LFBS
```

ビルドに必要なパッケージをインストールします。

Serene LinuxやFedoraの場合
```bash
dnf install -y squashfs-tools grub2 grub2-tools-extra e2fsprogs grub2-efi-ia32-modules grub2-efi-x64-modules dosfstools xorriso perl perl-core
```
Arch Linuxの場合
```bash
yay -S dnf squashfs-tools xorriso dosfstools grub2 squashfs-tools perl 
```

### 手動でオプションを指定してビルドする

`build.sh`を実行して下さい。

```bash
sudo ./build.sh [options] [channel]
```

### build.shの使い方

主なオプションは以下のとおりです。

完全なオプションと使い方は`./build -h`を実行して下さい。

用途 | 使い方
--- | ---
ブートスプラッシュを有効化 | -b
日本語にする | -l ja
出力先ディレクトリを指定する| -o [dir]
作業ディレクトリを指定する | -w [dir]
デバッグメッセージの有効化 | -d

##### 注意
チャンネル名以降に記述されたオプションは全て無視されます。

必ずチャンネル名の前にオプションを入れて下さい。

#### 例
以下の条件でビルドするにはこのようにします。

- Plymouthを有効化
- 作業ディレクトリを指定 `/tmp/lfbs`
- 出力ディレクトリを指定 `~/lfbs-out`

```bash
./build.sh -b -w /tmp/lfbs -o ~/lfbs-out
```

### 注意事項

#### チャンネルについて
チャンネルは、インストールするパッケージと含めるファイルを切り替えます。

この仕組みにより様々なバージョンのSerene Linuxをビルドすることが可能になります。

2021年2月4日現在でサポートされているチャンネルは以下のとおりです。

完全なチャンネルの一覧は`./build.sh -h`を参照して下さい。

名前 | 目的
--- | ---
serene | ubuntuベースのSerene linuxをFedoraに移植したチャンネル
lxde | LXDEと最小限のアプリケーションのみが入っている軽量なチャンネル
i3 | i3を搭載したrelengを除いて最も軽量なチャンネル(未整備)
releng | 純粋なFedora Linuxのライブ起動ディスクをビルドできるチャンネル
