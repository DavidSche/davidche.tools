# gradle 常用操作
解压gradle，将gradle/bin 添加到path中

## 设置gradle 的本地缓存目录

方法一，修改gradle启动脚本，进入gradle安装的bin目录，使用文本编辑器打开gradle.bat文件，在如图的位置添加以下语句

set GRADLE_OPTS="-Dgradle.user.home=D:\Users\shaowei\.gradle"

linux 环境
```
 $ export PATH=$PATH:/opt/gradle/gradle-5.5.1/bin
```
方法二，新建一个环境变量设置，GRADLE_USER_HOME，值为D:\Users\shaowei\.gradle，设置完成之后，点击确定，关闭设置窗口。这个时候可以去idea中看下gradle的用户目录，自动变成了环境变量中的值了

方法三，修改gradle.properties文件，增加一句
gradle.user.home=D\:\\Android\\.gradle



### gradle 缓存目录
.gradle目录

目录	描述
caches	gradle缓存目录
daemon	daemon日志目录
native	gradle平台相关目录
wrapper	gradle-wrapper下载目录
