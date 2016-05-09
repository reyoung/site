---
date: "2016-05-09T19:12:00+08:00"
title: "使用Caddy/Hugo架设博客--Part 2. Caddy"
description: "简要介绍Caddy架设博客的方法"
tags: [ "http2", "caddy", "git" ]
topics: [ "博客", "瞎折腾" ]
toc     : ""
---

[上一次](how_to_deploy_blog_system)说到如何使用hugo做一个静态博客系统。这次，准备把这个静态博客系统部署到自己的服务器中。

我们使用的http server是caddy。其实，之前我自己架博客都是用lighttpd的，因为lighttpd的配置比较简单。但是，最近发现caddy的配置更简单。而且，只要上了caddy，就直接支持了GZip，http2，https等功能。

## Caddy

Caddy是一个用go语言编写的http服务器。自带支持了很多贴心的功能，包括:

* git
* http2
* https
* gzip
* markdown
* 等等

而且配置文件极其简单。

### 题外话: golang
最近很多网络方面的code，都在使用golang来进行编写。究其原因，可能有这么几点。

* 网络服务很多都相对简单。
  * 这里说简单倒不是好写，而是逻辑都比较清楚。像是这个http server其实各大开源程序做的都比较成熟，多方参考下，固话下来的逻辑其实还是非常简单清晰的。
  * 所以，并不需要很强的抽象能力。而不一定要上C++
* C++写起来并不舒服。
  * 其实现代的C++，内存管理，异步等功能都还是比较好做的了。
  * 但是，一来会的人少，二来也没那么时髦，三来确实也不太舒服。

所以，golang现在越来越火。不过，golang的问题也是这些。在业务逻辑比较复杂，团队对cpp比较了解，那还是cpp是首选。

### Caddy的安装

caddy的官网提供了一个非常舒服的[下载界面](https://caddyserver.com/download)。只需要选择相应的插件，点击下载，二进制就下载到本地了。

将这个文件解压缩，放置到PATH里面，caddy便安装完成了。


### CaddyFile

CaddyFile是Caddy的配置文件，这里以我的博客的配置文件，简单的介绍一下caddy的配置文件。

    :2080
    gzip
    log ../access.log
    root .
    git github.com/reyoung/site ../repo {
        then hugo --destination=/home/www/www/
    }

第一行 :2080 表示http服务器监听2080端口。因为我自己的caddy程序不是以root身份运行的，所以不能监听到小于1024的端口。监听一个2080端口，再使用iptables转发过来。只需要调用
    
    iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 2080

即可转发端口80的TCP连接，到2080中。注意，要把网卡改成对应的名字。

第二行 开启gzip

第三行 access.log重定向到上级目录的access.log

第四行 web的根目录是当前目录

第五行 监听一个git地址(github.com/reyoung/site)。将这个git目录clone到上级目录的repo目录中。 当更新完毕的时候，在那个repo目录里执行hugo的编译。

至此，运行caddy即可以启动server，开启http服务了。

## Hugo、git、Caddy的其他坑

这里还有几个坑，

* caddy的git checkout的版本库，并没有初始化submodules，所以，需要手工到那个版本库路径里初始化一遍submodule
* caddy实际上有hugo的plugin，但是自己没太搞。其实只用git的plugin应该也挺简单的了。
* git版本库不是立即更新的，而是有一个更新时长。默认一个小时，但是可以设置到5min
* caddy支持https，但是这里没有把https的端口开放，所以，就暂时不折腾了。因为小博客应该没有啥人攻击，所以剩下的也懒得弄了。


至此，caddy+hugo的博客系统就搭建出来了。虽然说了不少，但是其实干的事情还是挺简单的。