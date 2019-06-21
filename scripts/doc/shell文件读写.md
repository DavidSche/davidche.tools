# 使用cat和EOF添加多行数据使用cat和EOF添加多行数据

当需要将多行文件输入到文本时，如果每条都使用echo 到文件时是比较繁琐的，这种情况下可以使用cat EOF进行多行文件的覆盖或追加输入。

## 一、覆盖
这里有两种格式可以使用

### 1、格式一

``` shell
#!/bin/bash
cat << EOF > /root/test.txt
Hello!
My site is www.361way.com
My site is www.91it.org
Test for cat and EOF!
EOF
```

### 2、格式二

``` shell
#!/bin/bash
cat > /root/test.txt <<EOF
Hello!
My site is www.361way.com
My site is www.91it.org
Test for cat and EOF!
EOF
```

两种写法区别无法是要写入的文件放在中间或最后的问题，至于选哪种看个人喜好吧。

## 二、追加

覆盖的写法基本和追加一样，不同的是单重定向号变成双重定向号。

### 1、格式一

``` shell
#!/bin/bash
cat << EOF >> /root/test.txt
Hello!
My site is www.361way.com
My site is www.91it.org
Test for cat and EOF!
EOF
```

### 2、格式二

``` shell
#!/bin/bash
cat >> /root/test.txt <<EOF
Hello!
My site is www.361way.com
My site is www.91it.org
Test for cat and EOF!
EOF
```

需要注意的是，不论是覆盖还是追加，在涉及到变量操作时是需要进行转义的，例如：

``` shell
#!/bin/bash
cat <<EOF >> /root/a.txt
PATH=\$PATH:\$HOME/bin
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/10.2.0/db_1
export ORACLE_SID=yqpt
export PATH=\$PATH:\$ORACLE_HOME/bin
export NLS_LANG="AMERICAN_AMERICA.AL32UTF8"
EOF
```
