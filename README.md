pm_corosync01 Cookbook
======================
CentOS 6.x/7.x で Pacemaker と Corosync を使って、マスタースレーブのクラスタを作るクックブックです。

開発中



システム構成  修正中
------------
このクックブックで構築する構成を次の図に表します。サービスを提供するためのVIPは、Portable SubnetのIPアドレスを利用します。アクティブとスタンバイのサーバーは、物理（ベアメタル）サーバーでも構いません。これらのサーバーにPacemaker + Corosync を設定します。主サーバーが停止した場合、待機サーバーが、VIPを引継ぎ、ファイルシステムのマウント、サービス起動など自動で進め、サービスを継続します。主サーバーと待機サーバーの相互監視はマルチキャストを利用するため、設定ファイルにクラスタのリストを設定する必要がありません。マルチキャストの同じグループに属するサーバーがクラスタのメンバーとなります。

![System Configuration](doc/Pacemaker_config.png)


前提条件
------------
**オペレーティングシステム**
* CentOS 7.x - Minimal Install (64 bit) 
* CentOS 6.x - Minimal Install (64 bit) 


**サーバー**
* 主サーバー　(アクティブ）
* 待機サーバー (スタンバイ)


**ネットワーク**
* ポータブルサブネットをオーダーして、同じVLANに割り当て
* VLAN Spanning : ON 



アトリビュ−ト
------------
VIPを含むネットワーク関連の設定が必須です。

#### pm_corosync01::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>["network_addr"]</td>
    <td>サブネット</td>
    <td>クラスタメンバーが接続するネット</td>
    <td>NULL (必須)</td>
  </tr>
  <tr>
    <td>["multicast_addr"]</td>
    <td>マルチキャストアドレス</td>
    <td>クラスタメンバーは要同一アドレス</td>
    <td>NULL (必須)</td>
  </tr>
  <tr>
    <td>["multicast_port"]</td>
    <td>マルチキャストポート</td>
    <td>クラスタメンバーは要同一ポート</td>
    <td>NULL (必須)</td>
  </tr>
  <tr>
    <td>["vip_ipaddr"]</td>
    <td>仮想IPアドレス</td>
    <td>ポータルIPから割り当て</td>
    <td>NULL (必須)</td>
  </tr>
  <tr>
    <td>["vip_netmask"]</td>
    <td>サブネットマスク</td>
    <td>ポータルIPのサブネットマスクをセット</td>
    <td>NULL (必須)</td>
  </tr>
</table>



使い方
------------
最小限の操作で適用する方法です。この操作は、各サーバーにログインして操作が必要です。

```
# curl -L https://www.opscode.com/chef/install.sh | bash
# knife cookbook create dummy -o /var/chef/cookbooks
# cd /var/chef/cookbooks
# git clone https://github.com/takara9/pm_corosync01
```
アトリビュートを編集して、次のコマンドでサーバーに適用する。

```
# chef-solo -o pm_corosync01
```

Knife solo, Knife zoro, Knife + Chef server を利用して、リモートや集中管理で適用する場合は、それぞれのコマンドの使用法に従って実施してください。



License and Authors
-------------------

Authors: Maho Takara (高良 真穂)

License: see LICENSE File
