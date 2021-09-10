 #  高效 Bash 使用技巧
简介  这篇文章主要介绍了高效 Bash 使用技巧以及相关的经验技巧，文章约7414字，浏览量476，点赞数6，值得推荐！

这是一篇 Bash 的使用技巧内容，部分内容需要先具备一些基础知识及 Linux 的基础操作能力
主要内容分两部分，一部分是关于 history 的，另一部分是关于操作的

我们在日常使用中，难免会使用到一些历史命令或者有时需要对历史命令进行更正，那么如何更加高效的来完成这些操作呢？

History
history 格式化

## history 命令

首先我们肯定会想到 history 命令，history 可以返回之前使用过的命令列表，就像这样:

```
(Tao) ➜  ~ history 10
    1  cd myzh
    2  cd zsh
    3  ls
    4  cat zshrc
    5  brew info tmux
    6  brew install tmux
    7  cd .tmux
    8  cd tmux
    9  cp tmux.conf ~/
   10  mv tmux.conf .tmux.conf
```

我们可以很方便的通过后面指定数字来返回固定数量的历史记录，但是这样得到的结果，我们也只是知道使用它们的先后顺序，我们想要得到更加详细的信息，例如执行时间，那么我们可以这样做：

```
(Tao) ➜  ~ export HISTTIMEFORMAT='%F %T '

(Tao) ➜  ~ history 10
    1 2016-02-09 15:38:40  cd myzh
    2 2016-02-09 15:38:44  cd zsh
    3 2016-02-09 15:38:51  ls
    4 2016-02-09 15:38:59  cat zshrc
    5 2016-02-09 15:39:04  brew info tmux
    6 2016-02-09 15:48:13  brew install tmux
    7 2016-02-09 15:48:17  cd .tmux
    8 2016-02-09 15:49:04  cd tmux
    9 2016-02-09 15:49:23  cp tmux.conf ~/
   10 2016-02-09 15:49:47  mv tmux.conf .tmux.conf
```

通过设置 HISTTIMEFORMAT 的环境变量，在历史记录中显示了时间。

## 使用指定历史命令

想要使用某条历史记录改如何操作呢？ 我们使用 !序号, 比如我们想要执行第3条命令，那我们输入 !3 即可：

```
(Tao) ➜  ~ history 6
    1  cd myzh
    2  cd zsh
    3  ls
    4  cat zshrc
    5  brew info tmux
    6  brew install tmux

(Tao) ➜  ~ !3
(Tao) ➜  ~ ls

zshrc
```

重复执行了上面第 3 条命令。 如果我们想要执行倒数第n条，那就直接输入 !-n 。

## 使用上条命令

当想要使用上条命令的时候，我们有下面 4 种方式：

!-1 回车
!! 回车
输入 Ctrl + p 回车
按上箭头回车
有兴趣的小伙伴可以试下，这几种用法都比较常见。

使用某些字符开头或者包含这些字符在内的命令
比如，我们想要使用之前执行过的一条导入环境变量的语句，那么我可以执行 !export:

# 当然export也可以不输完整
```
(Tao) ➜  ~ !export    
(Tao) ➜  ~ export HISTTIMEFORMAT='%F %T '
```

如果只记得命令中包含 xport 呢？ 那当然也可以， 只要加个 ? 就可以：

```
(Tao) ➜  ~ !?xport    
(Tao) ➜  ~ export HISTTIMEFORMAT='%F %T '
```

获取上条命令中的参数
比如 touch 了某个文件，现在要编辑它，那么只要执行 !$ 或者 !!:$ 即可：

(Tao) ➜  ~ touch test.sh   
(Tao) ➜  ~ vi !$   
vi test.sh

(Tao) ➜  ~ vi !!:$
vi test.sh
这种方式只是获取到了最后一位的参数， 那么假如我们想要获取的不只是最后一个参数呢？使用 !* 或者 !!:* 即可：

```
(Tao) ➜  ~ touch a b c
(Tao) ➜  ~ vim !*
vim a b c
3 files to edit

(Tao) ➜  ~ vim !!:*
vim a b c
3 files to edit
```

对上条命令中的参数做替换
难免有手误的时候，那么如何快速进行替换呢？ 我们可以使用 ^old^new 的命令，例如：

```
(Tao) ➜  ~ cp /usr/local/etc/redis-sen.conf .
cp: /usr/local/etc/redis-sen.conf: No such file or directory
(Tao) ➜  ~ ^sen^sentinel
cp /usr/local/etc/redis-sentinel.conf .
```

或者 我们还可以使用 !!:gs/old/new 这样进行操作，例如：

```
(Tao) ➜  ~ cp /usr/local/etc/redis-sen.conf .
cp: /usr/local/etc/redis-sen.conf: No such file or directory
(Tao) ➜  ~ !!:gs/sen/sentinel
cp /usr/local/etc/redis-sentinel.conf .
```

如果我们只是部分内容做替换呢？ 该如何操作？

只要使用 !!:x-y 来选择上条记录中的参数范围，然后进行替换即可：

```
(Tao) ➜  ~ mkdir -p data/db1 data/dc2 data/dc3
(Tao) ➜  ~ mkdir -p !!:3-4:gs/c/b
mkdir -p data/db2 data/db3
```
组合使用
聪明的你应该已经发现, 上面我先写了如何使用历史命令，后来又介绍了如何对上条命令操作，那么把这两部分内容组合起来会产生什么样的效果呢？

```
(Tao) ➜  ~ mkdir -p data/db1 data/dc2 data/dc3
(Tao) ➜  ~ ls **/**
data/db1:

data/dc2:

data/dc3:
(Tao) ➜  ~ mkdir -p !mkdir:3-4:gs/c/b
mkdir -p data/db2 data/db3
(Tao) ➜  ~ ls **/**
data/db1:

data/db2:

data/db3:

data/dc2:

data/dc3:
```

对，就像上面这样，我们可以通过各种组合来是我们对以前命令的修改执行更加灵活方便！ Enjoy it !

## 操作部分

操作快捷键(emacs 模式)
Ctrl + a : 光标返回首位
Ctrl + e : 光标移至末尾
Ctrl + p : 上一个命令
Ctrl + n : 下一个命令
Ctrl + l : 清屏
Ctrl + d : 删除当前光标处的内容
Ctrl + h : 回退一位
Ctrl + b : 光标向左一位
Ctrl + f : 光标向右一位
Ctrl + u : 剪切光标前的内容(全部)
Ctrl + w : 剪切光标前的内容(按词)
Ctrl + k : 剪切光标后的内容
Ctrl + y : 将剪切的内容复制到光标后
Ctrl + t : 交换光标前的两个字符顺序
设置操作模式为 Vi 模式
set -o vi

## 搜索

Ctrl + r : 搜索历史中输入过的命令