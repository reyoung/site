---
date: "2016-04-29T22:19:00+08:00"
title: "使用Caddy/Hugo架设博客--Part 1. Hugo"
description: "简要介绍Caddy架设博客的方法"
tags: [ "go", "git", "git submodule", "hugo", "blog" ]
topics: [ "博客", "瞎折腾" ]
toc	: ""
---

最近瞎折腾换VPS，顺便就把之前的博客系统换了。

之前使用的博客系统是[gor](https://github.com/wendal/gor),不过感觉作者也不算太维护了。不过也正常，毕竟大家都忙于工作，能够在百忙之中写一些东西给大家用，还是很感谢作者的。

而且，当时(三年前？)的做那个博客的时候可选项很少。仅有的可选项也就是ruby写的那些静态博客系统，或者wordpress。各有些不爽的地方。

* Ruby的[jekyll](https://jekyllrb.com/)。不过还是感觉ruby各种奇怪和难用(也是我不咋会ruby)，比如版本从1.8.x到1.9.x共存啊之类的。用了[rvm](https://rvm.io/)也没舒服到哪去。
* Wordpress的话。首先跑一个php也是毕竟耗资源的，但其实像博客这种很静态的东西，有必要跑个php+mysql么？并且，wordpress经常有垃圾评论(spam)，而且还会各种被试密码，扫漏洞。如果用静态的网站，也就随便扫啦。

所以，之前便选择了gor作为博客引擎。然后使用lighttpd作为静态文件的http server。为啥要使用ligttpd呢？因为我当时觉得lighttpd是靠谱的http server里面，配置文件最符合直觉/简单的。

然后，在那个VPS上加一个git版本库，加一个push的hook，每次push的时候自动生成静态文件，即把博客架起来了。

过了这么些年，技术也是日新月异。最近比较好玩的http server可以说是Caddy。然后博客引擎也换成了社区更多的Hugo。感觉配置起来也变得越来越简单了。

## Hugo架设博客
[Hugo](https://gohugo.io/)使用golang编写的一个快速的博客引擎。从官网上看，还是很好看的。选择hugo的原因是:

* hugo是使用golang编写的博客引擎，所以有了golang的各种好处。
  * 编译执行，速度快，资源占用少。相比于ruby，python写的静态博客引擎，渲染博客的速度很定要好很多。
  * golang的默认状态是静态链接，编译好了之后，就一个二进制文件。这个让部署系统变得非常简单。
* hugo支持的theme和插件还是很多的。code highlight，latex的公式等等。基本上常用写博客的工具，hugo全部支持。

### 下载编译hugo

#### 下载Go语言编译器
得益于hugo使用golang编写，编译下载hugo是非常简单的。首先要去安装golang的编译器。目前这个版本的hugo需要go的版本<s>1.5</s>1.3以上。

下载go还是非常简单的。在mac上，直接

{{< highlight bash >}}
brew install go
{{</highlight >}}

即可下载go的编译器。

而在Server端，也就是博客的系统里，也要安装go语言的编译器。这里，使用新版的go可能就有些麻烦了。如果是使用CentOS，可能就要各种蛋疼了。不过我还是习惯于使用Debian。在Debian里面就比较简单了，将Debian切到sid下，apt里面就有新版的golang了。具体方法如下

1. 将 /etc/apt/sources.list里面的版本切到sid
  1. 可能之前是Wheezy或者stable，whatever，替换掉就好了。
  2. 类似把deb http://mirrors.ustc.edu.cn/debian/ wheezy main contrib non-free替换成deb http://mirrors.ustc.edu.cn/debian/ sid main contrib non-free
2. 更新debian
{{< highlight bash >}}
sudo apt-get update
sudo apt-get dist-upgrade	# 这个是升级版本！会把所有已经安装的包升级到sid上。也许很危险哦。
{{</highlight >}}
3. 安装go
{{< highlight bash >}}
sudo apt-get install golang-go
{{</highlight >}}

完事后，为了安装hugo或者其他的golang的第三方库，还要安装git。使用apt-get install git或者brew install git就好啦。

#### 设置GOPATH

GOPATH是golang代码和二进制存放的地方。一般开发也在gopath里面比较好。

{{< highlight bash>}}
mkdir $HOME/gopath
echo 'export GOPATH=$HOME/gopath' > ~/.bashrc
echo 'export PATH=$GOPATH/bin:$PATH' > ~/.bashrc
source ~/.bashrc
{{</highlight>}}

运行上述脚本，即可以设置GOPATH，并且把GOPATH的bin目录放置到PATH中。(当然，我其实使用fish shell的，写bash是为了大家看的)

#### 下载安装Hugo

{{< highlight bash>}}
go get -u -v github.com/spf13/hugo
{{</highlight>}}

这样一个命令就下载安装完Hugo了。不过，安装过程可能比较长，毕竟要下载各个依赖库。下载使用的是git。

### 使用hugo建一个新的站点。

在命令行中，键入
{{< highlight bash>}}
hugo new site YOUR_SITE_DIRECTORY
{{< /highlight>}}
就可以新建一个site了。

新建完site，按照命令行提示，要去下载和选择一个theme，或者手写一个theme。手写一个theme可能更是前端人员喜欢的事情。作为一个前端渣，还是不没事自己整一个theme了。在shell里面，命令提示从 https://themes.gohugo.io 上选择一个theme。不过，我找了半天也没找到从哪下这些theme。

后来发现，hugo的theme都托管在官方的git[版本库](https://github.com/spf13/hugoThemes)里了。同时，我也想把我的博客托管到git里，于是，边将整体使用git submodule来管理起来了。

{{< highlight bash>}}
cd YOUR_SITE_DIRECTORY
git init
git add .
git commit -m "Init Commit"  # 第一个版本

git submodule add https://github.com/spf13/hugoThemes.git themes 
# 将hugoThemes作为一个submodule，放置到themes目录
git submodule update --recursive # update submodules
cd themes # 因为hugoThemes也是用submodule管理的，所以做一样的事情。
git submodule init
git submodule update --recursive # update submodules

{{< /highlight>}}

将所有的themes下载完毕后，就可以从官方的[theme展示网站](https://themes.gohugo.io)选择一个舒服的主题啦。

选择完主题后，按照主题里的提示，修改config.toml即可以激活主体。

使用huge server，便可以启动一个本地的server，显示博客的样子啦。

### 新建一个文章

在content目录下，建立一个markdown文件，即可以新建一个文章。在这个目录下的markdown都会被渲染成一个html。同时，这个目录也是网站的根目录。

新建文章的时候，除了简单的markdown以外，还有一些元数据用来告诉渲染器，这篇博客的一些属性。具体示例可以参考官方[示例](https://gohugo.io/content/example/)。摘录如下:

{{< highlight md>}}
+++
date        = "2013-06-21T11:27:27-04:00"
title       = "Nitro: A quick and simple profiler for Go"
description = "Nitro is a simple profiler for your Golang applications"
tags        = [ "Development", "Go", "profiling" ]
topics      = [ "Development", "Go" ]
slug        = "nitro"
project_url = "https://github.com/spf13/nitro"
+++
# Nitro

Quick and easy performance analyzer library for [Go](http://golang.org/).

## Overview

Nitro is a quick and easy performance analyzer library for Go.
It is useful for comparing A/B against different drafts of functions
or different functions.

## Implementing Nitro

Using Nitro is simple. First, use `go get` to install the latest version
of the library.

    $ go get github.com/spf13/nitro

Next, include nitro in your application.
{{</highlight>}}

如此，简单的使用Hugo架设博客和渲染博客就已经搞定啦。只要再

{{<highlight bash>}}
git add .
git commit -m "new post"
git push
{{</highlight>}}

即可以把新文章push到服务器上存起来了。至此，第一部分，使用hugo架设博客就写的差不多了，[下一篇](/post/how_to_deploy_blog_system_part2/)文章会写如何使用Caddy这个http server来在服务器上把博客serve出去。

### 如果没有VPS怎么办？

Well，你可以:

* 在博客的目录里，执行hugo，然后将public目录下的文件，复制到你的空间里。这个空间可以被http访问到。
* 或者，将博客托管到github page上。官方有[教程](https://gohugo.io/tutorials/github-pages-blog/)，我就不在赘述了。