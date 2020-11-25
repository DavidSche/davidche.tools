# Redis使用lua脚本

Redis在2.6推出了脚本功能，允许开发者使用Lua语言编写脚本传到Redis中执行。使用脚本的好处如下:

- 1.减少网络开销：本来5次网络请求的操作，可以用一个请求完成，原先5次请求的逻辑放在redis服务器上完成。使用脚本，减少了网络往返时延。
- 2.原子操作：Redis会将整个脚本作为一个整体执行，中间不会被其他命令插入。
- 3.复用：客户端发送的脚本会永久存储在Redis中，意味着其他客户端可以复用这一脚本而不需要使用代码完成同样的逻辑。

> 客户端如果想执行Lua脚本，首先 在客户端编写好Lua脚本代码，然后把脚本作为字符串发送给服务端，服务 端会将执行结果返回给客户端

实现一个访问频率控制，某个ip在短时间内频繁访问页面，需要记录并检测出来，就可以通过Lua脚本高效的实现。

在redis客户端机器上，新建一个文件ratelimiting.lua，内容如下，lua脚本位置默认在data目录可以访问，其他目录调用时指定目录即可。

**ratelimiting.lua**

```
local times = redis.call('incr',KEYS[1])

if times == 1 then
    redis.call('expire',KEYS[1], ARGV[1])
end

if times > tonumber(ARGV[2]) then
    return 0
end
return 1
```

在redis客户端机器上，测试脚本。这里以之前配置的docker-redis-cluster环境测试。

```
redis-cli -a 123456 -c --eval ratelimiting.lua rate.limitingl:127.0.0.1 , 10 3
```

--eval参数是告诉redis-cli读取并运行后面的Lua脚本，ratelimiting.lua是脚本的位置，后面跟着是传给Lua脚本的参数。其中","前的rate.limiting:127.0.0.1是要操作的键，可以再脚本中用KEYS[1]获取，","后面的10和3是参数，在脚本中能够使用ARGV[1]和ARGV[2]获得。注：","两边的空格不能省略，否则会出错

结合脚本的内容可知这行命令的作用是将访问频率限制为每10秒最多3次，所以在终端中不断的运行此命令会发现当访问频率在10秒内小于或等于3次时返回1，否则返回0。

测试运行如下：

```
root@469f2a22132c:/data# redis-cli -a 123456 -c --eval ratelimiting.lua rate.limitingl:127.0.0.1 , 10 3
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
(integer) 1
root@469f2a22132c:/data# redis-cli -a 123456 -c --eval ratelimiting.lua rate.limitingl:127.0.0.1 , 10 3
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
(integer) 1
root@469f2a22132c:/data# redis-cli -a 123456 -c --eval ratelimiting.lua rate.limitingl:127.0.0.1 , 10 3
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
(integer) 1
root@469f2a22132c:/data# redis-cli -a 123456 -c --eval ratelimiting.lua rate.limitingl:127.0.0.1 , 10 3
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
(integer) 0
root@469f2a22132c:/data# redis-cli -a 123456 -c --eval ratelimiting.lua rate.limitingl:127.0.0.1 , 10 3
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
(integer) 0
```



本案例只是简单的介绍redis使用lua脚本，实际项目中lua脚本加载到redis内存后通过evalsha调用，避免重复加载。如下:

```
# redis-cli script load "$(cat lua_get.lua)" "7413dc2440db1fea7c0a0bde841fa68eefaf149c"redis-cli script load "$(cat lua_get.lua)"

127.0.0.1:6379> evalsha 7413dc2440db1fea7c0a0bde841fa68eefaf149c 1 redis world "hello redisworld"
```



