# 使用 jq 处理json

使用以下json测试文件

```FunTester.json
{
    "name": "FunTester",
    "article": [{
            "author": "tester1",
            "title": "ApiTest"
        }, {
            "author": "tester2",
            "title": "performanceTest"
        }
    ]
}
```

jq可以使用一个或多个过滤器作为参数。最简单的过滤器是.。返回整个JSON数据的内容;

```shell
# echo '{"name":"FunTester"}' | jq '.' 
{
  "name": "FunTester"
}

可以向过滤器添加一个简单的对象标识符。为此，我们将使用前面提到的FunTester.json文件。通过.name获取名字的内容

#cat FunTester.json | jq '.name'
"FunTester"

```

可以使用[]语法获取数组信息：

```shell
# cat FunTester.json | jq '.article[1]'
{
  "author": "tester2",
  "title": "performanceTest"
}

```

可以将这两个语法组合起来：

```shell
]# cat FunTester.json | jq '.article[1].title'
"performanceTest"

```

提取数组对象中某一个key的value集合，可以这么写：

```shell
#  cat FunTester.json | jq '.article[].title'
"ApiTest"
"performanceTest"

```

## 处理响应

当然，我们也可以用jq处理响应结果。这是一个jq常见用法，我用moco API封装框架，将上面的JSON数据当做一个接口的响应。

用curl命令访问接口，并获取响应结果，然后使用jq命令获取一些值的集合。

```shell
FunTester:Downloads fv$ curl http://localhost:12345/jq/test | jq '.name,.article[1].author'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   223  100   223    0     0  13937      0 --:--:-- --:--:-- --:--:-- 13937
"FunTester"
"tester2"

```

## 对于对象的处理

1). 因为对象里面的每个元素都是 key:value的形式存在，虽然value 也可以是一个复合类型，但是不影响 key:value 这种格式，所以对于对象，通常用 jq .key 这种方式来获取对应key的value. 其中key 在这里可以不用引号括起来,当然也可以用引号括起来,反正key都是字符串类型。
2). 如果要获得对象所有元素的key值，那么要把 |keys 串接在对象后面，需要注意的是 这里不是利用的shell的管道，而是jq内置的管道，所以属于jq的参数的一部分. 例如

## 判断是否存在某个key.

在上面利用jq内置的 keys 属性，可以获取所有的key, 其实还有jq内置的has 方法，这个方法可以判断对应的key是否存在. 例子如下：

```shell
[root@localhost ]# cat t | jq '.[0]|has("users")'
false
[root@localhost ]# cat t | jq '.[0]|has("user")'
true
[root@localhost ]# 
```

## 4). jq 的查找结果避免输出 错误，转而输出null

在查找条件的后面加上一个问号，那么如果找不到就不会输出任何的error, 相应的输出一个null来替代. 这个问号可以加在方法的后面(后面的例子中可以看到)。这在递归查找的时候非常有用;否则可能会出现报错的情形.

## 5). jq 的查找结果为空，避免输出null ,而是什么都不输出

目前不知道怎么实现，暂且用其他的linux 命令来过滤吧

## 6). 根据指定的关键字查找有该关键字的key，也就是模糊查找

jq 支持PCRE 正则表达式，所以支持模糊搜索， 这里主要展示用scan 方法输出模糊搜索的结果. 用法实例如下：

```shell
[root@localhost Desktop]# cat t | jq '.[]|keys?|.[]|scan(".*ten.*",".*Ten.*",".*id.*")?'    #首先去掉 json 数组的 [ ] 符号， 然后调用keys 属性获得对应的keys 值，这时候的类型依然变成了数组，所以再次去掉数组的标志符号，从而变成了字符串，把这个字符串传递给scan 方法，从而输出模糊匹配的结果. 
"homeTenantId"
"id"
"managedByTenants"
"tenantId"
"id"
```

## 7). 根据指定的key, 查找嵌套对象中所有该key的value,输出该value

使用 .. 或者 recurse 来表示递归查找，然后通过管道进行常规的查找就可以了，举例如下：

```shell
[root@localhost Desktop]# cat t | jq 'recurse|.id?'
"c22b1b54-fa25-4901-ad3f-d91836a747b8"
null
{
  "user": "multiple"
}
null
[root@localhost Desktop]# cat t | jq 'recurse|.user?'   #使用 recurse 内置方法
{
  "name": "1Da",
  "type": "sDl"
}
null
null
"multiple"
[root@localhost Desktop]# cat t | jq '..|.user?'        #使用 .. 来表示递归，和recurse 一样；
{
  "name": "1Da",
  "type": "sDl"
}
null
null
"multiple"
```

## 8). 如何将匹配key 的 key 和value 一起进行输出?

```shell
az vm get-instance-view -g rgtest -n rheltest |jq  '..|{name:.name?}'

yan@Azure:~$ az vm get-instance-view  -g rgtest -n rheltest | jq '..|{name:.name?}|select(.name!=null)'       #通过select 方法实现非空输出,并且输出结果是key:value的方式
{
  "name": "rheltest"
}
{
  "name": "rheltest_OsDisk_1_beee1fadb3de4ac0846a48c9df7c73b5"
}
{
  "name": "OmsAgentForLinux"
}
{
  "name": "rheltest_OsDisk_1_beee1fadb3de4ac0846a48c9df7c73b5"
}

yan@Azure:~$ az vm get-instance-view  -g rgtest -n rheltest | jq '..|.name?|select(.!=null)'      #通过select进行非空输出，并且输出结果是 value方式；
"rheltest"
"rheltest_OsDisk_1_beee1fadb3de4ac0846a48c9df7c73b5"
"OmsAgentForLinux"
"rheltest_OsDisk_1_beee1fadb3de4ac0846a48c9df7c73b5"

```

以上的命令表示递归方式，获取Key为name的所有key:value对，并以key:value的方式进行输出，但是空的字典对象如何排除呢？ 目前还没有发现好的解决方法

## 9). 因为keys 属性支持对象的同时，也支持数组，所以如何来剔除数组而只是要对象的keys呢？

有一个walk 方法可以实现，但是不常用，所以这里不做讨论.

## 10).嵌套的模糊查找，上面描述了用scan进行模糊查找，以及用recurse来进行嵌套，如何两者结合呢？

因为scan方法只能够作用于字符串，所以不可以简单的将recurse和scan 结合起来使用，这里需要通过keys来实现 嵌套的模糊查询. 举例如下：

```shell
[root@localhost Desktop]# cat t | jq '.[]|keys?|.[]|scan(".*use.*")?'  #直接的模糊查询，只能找到一个key.
"user"
[root@localhost Desktop]# cat t | jq '.[]|..|keys?|.[]|scan(".*use.*")?' #先通过嵌套输出所有的key, 然后再模糊查询. 得到的是两个key. 
"user"
"user"
[root@localhost Desktop]# 
```

## 11). 其他使用小tips：

在可以使用 .key1.key2 这种情况下，也可以使用 .key1|.key2 的格式，个人更倾向于使用 .key1|.key2 ，因为看起来更清晰明了. 比如下面的例子.

```shell
[root@localhost Desktop]# cat t| jq .[0].user
{
  "name": "1c56a18a-8458-486d-85a9-2e2ac4db47da",
  "type": "servicePrincipal"
}
[root@localhost Desktop]# cat t| jq .[0]|.user
bash: .user: command not found...
[root@localhost Desktop]# cat t| jq '.[0]|.user'
{
  "name": "1c56a18a-8458-486d-85a9-2e2ac4db47da",
  "type": "servicePrincipal"
}
[root@localhost Desktop]# 
```

在大多数情况下我们看到的json 复合格式最外层都是数组的形式，而不是对象的形式，这个是因为什么原因呢？ 因为json的对象必须是 key:value 的格式，虽然value 也可以是一个复合格式，但是一定需要key:value 形式，而 数组的不同元素的类型之间没有任何的关联，同一个数组，既可以包含有字符串元素，也可以包含对象元素，还可以包含数字... ，因此一个复合类型的 json格式一般最外层都是数组的形式.

```shell
#echo '[1,2,3,4,5,6,7,8,9,10]' | jq '.[:6]' | jq '.[-2:]'
[
  5,
  6
]

```