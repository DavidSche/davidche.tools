linux--mail设置smtp发送邮件

日期：20171104

邮件，或许在win中不怎么用到。（因为我们大多数用QQ、微信即时聊天，软件自动推送新闻）
但在linux中，如果经常逛论坛（外国），或者源码官网，都会发现有“订阅邮件列表”的功能。
（邮件列表是什么？我也不太了解，应该相当于订阅新闻之类的东东。我订阅过一个网站，然后每次一有新消息，就会发来我邮箱）

不管邮件列表是什么，在linux中，想通信，发邮件是个好方法

send配置复杂，选用smtp
昨天发现了一个好东东，mail，用来收发邮件的。
然后注意到自己用了那么久的linux，还没发过邮件，就想要试试。毕竟，为了记录别人hack你，好用而且安全方法有，
1、把日志信息打印出来
2、发送到你的邮箱
第1种方法就算了，毕竟不是人人的都有打印机，再说那很浪费纸张。选用第2种比较好。

但是第一次尝试mail失败后，发现mail只是一个外壳，需要其他程序的支持，sendmail就是常用的一个，当然还有其他类似sendmail程序。

百度sendmail，那配置不是一般的难，各种失败后，我就放弃折腾了（以后再说。。。）

那有没有其他简单方法呢？
有，那就是使用smtp，Simple Mail Transfer Protocol，简单邮件传输协议。

简单的配置mail
在/etc/mail.rc后面加上，（这文档需要root权限）
```.rc
...

set from=ipenx@qq.com
set smtp=smtp.qq.com
set smtp-auth-user=ipenx@qq.com
set smtp-auth-password=jdxeqwaxbxiosoqp ##<--这里填的是邮箱授权码
set smtp-auth=login
```


解释，
1、from，是你的邮箱，发送邮件的源邮箱
2、smtp，是提供smtp服务的服务商地址。通常为smtp.（你的邮箱服务商，qq，163之类的）.com，具体可以看看你用的邮箱。
3、smtp-auth-user，使用的邮箱。？？？这和from有什么区别？
4、smtp-auth-passwd，邮箱授权码。邮箱开启pop3/smtp的时候，一般会给你的。
5、smtp-auth，选用的协议。网上多数是这么说的，但是觉得有点奇怪。

注：smtp-auth-password，是邮箱授权码，并非你邮箱登录密码。（网上好多教程都没说，害我一直以为是登录密码）

好了，可以测试一下，按网上说，做了以上配置就可以发邮件了。

$ echo Hello World | mail -s test 2625722733@qq.com

不知道大家可不可以，反正我不可以，并提示，

mail: smtp-server: 530 Error: A secure connection is requiered(such as ssl)

错误提示说，需要ssl之类的加密呢！

配置ssl加密
再在/etc/mail.rc后面添加
```.rc
set smtp-use-starttls
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb/
```

参数具体作用貌似是ssl相关的，有兴趣的朋友，自行找资料。

再来测试一下，

$ echo Hello World | mail -s test 2625722733@qq.com

到这里，我就成功利用我“ipenx@qq.com”的邮箱发送邮件到另一个邮箱“2625722733@qq.com”。

```editorconfig

set from=aimei_jn@163.com
set smtp=smtp.qiye.163.com
set smtp-auth-user=aimei_jn@163.com
set smtp-auth-password=jdxeqwaxbxiosoqp ##<--这里填的是邮箱授权码
set smtp-auth=login
set smtp-use-starttls
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb/


set from=1665***913@qq.com
set smtp=smtp.qq.com
set smtp-auth-user=1665***913@qq.com
set smtp-auth-password=yslsnzvgqqtadhee QQ邮箱授权码，需要开启pop3和smtp就会生成
set smtp-auth=login
set smtp-use-starttls             SSL验证信息
set ssl-verify=ignore              SSL验证信息
set nss-config-dir=/etc/pki/nssdb/      SSL验证信息
```

邮箱开启smtp
如果遇到，503错误，

smtp-server: 535 Error

那代表你的邮箱还没开启smpt服务。
例如，QQ邮箱登录后，设置–>帐号–>pop3/smtp，开启，然后QQ邮箱还会给出授权码，就是上面配置时候填的smtp-auth-passwd。
