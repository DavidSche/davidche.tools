# k8s 

## 标签
spec.selector.matchLables实验
  - 1.1 正确的Deployment书写方式，是要让spec.selector.matchLabels值和spec.template.metadata.lables值完全匹配
  - 1.2 如果不写spec.selector.matchLabels字段的内容，直接创建则会报错：缺少必要字段selector
  - 1.3 当spec.selector.matchLabels匹配的键值，与spec.template.metadata.lables键值不相对应，也会直接报错：选择的和模板标签不匹配
  - 在deployment.yaml中必须写spec.selector.matchLabels
  - 在定义pod模板时，必须定义spec.template.metadata.lables，因为spec.selector.matchLabels是必须字段，而它又必须和spec.template.metadata.lables的键值一致。
  - spec.template.metadata.lables里面定义的内容，会应用到spec.template.spec下定义的所有pod副本中，在spec.template.spec.containers里面不能定义labels标签

## kubectl port-forward 踩坑
kubectl port-forward 其作用 将主机的端口与集群中的端口连接起来
书上的案例多了一个--address参数。kubectl port-forward --help查看参数说明

```
Options:
- -address=[localhost]: Addresses to listen on (comma separated). Only accepts IP addresses or localhost as a value. When localhost is supplied, kubectl will try to bind on both 127.0.0.1 and ::1 and will fail if neither of these addresses are available to bind.
  这个参数用于设置监听地址，默认值是localhost。如果设置为localhost，那么k8s会监听127.0.0.1和::1这两个地址。

```

默认是localhost  127.0.0.1 ,如果其他机器访问，应添加参数  -- address
解决办法：kubectl port-forward 设置参数-- address 0.0.0.0










