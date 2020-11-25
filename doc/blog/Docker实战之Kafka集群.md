# 1. 概述

Apache Kafka是一个快速、可扩展的、高吞吐、可容错的分布式发布订阅消息系统。其具有高吞吐量、内置分区、支持数据副本和容错的特性，适合在大规模消息处理场景中使用。

笔者之前在物联网公司工作，其中Kafka作为物联网MQ选型的事实标准，这里优先给大家搭建Kafka集群环境。由于Kafka的安装需要依赖Zookeeper，对Zookeeper还不了解的小伙伴可以在 [这里](https://mp.weixin.qq.com/s/aNpn59gHD_WOhtZkceMwug) 先认识下Zookeeper。

Kafka能解决什么问题呢？先说一下消息队列常见的使用场景吧，其实场景有很多，但是比较核心的有 3 个：解耦、异步、削峰。

# 2. Kafka基本概念

Kafka部分名词解释如下：

* Broker：消息中间件处理结点，一个Kafka节点就是一个broker，多个broker可以组成一个Kafka集群。
* Topic：一类消息，例如page view日志、click日志等都可以以topic的形式存在，Kafka集群能够同时负责多个topic的分发。
* Partition：topic物理上的分组，一个topic可以分为多个partition，每个partition是一个有序的队列。
* Segment：partition物理上由多个segment组成，下面有详细说明。
* offset：每个partition都由一系列有序的、不可变的消息组成，这些消息被连续的追加到partition中。partition中的每个消息都有一个连续的序列号叫做offset,用于partition唯一标识一条消息.每个partition中的消息都由offset=0开始记录消息。

# 3. Docker环境搭建

配合上一节的Zookeeper环境,计划搭建一个3节点的集群。宿主机IP为 `192.168.124.5`。

**docker-compose-kafka-cluster.yml**

```yaml
version: '3.7'

networks:
  docker_net:
    external: true

services:

  kafka1:
    image: wurstmeister/kafka
    restart: unless-stopped
    container_name: kafka1
    ports:
      - "9093:9092"
    external_links:
      - zoo1
      - zoo2
      - zoo3
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ADVERTISED_HOST_NAME: 192.168.124.5                   ## 修改:宿主机IP
      KAFKA_ADVERTISED_PORT: 9093                                 ## 修改:宿主机映射port
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://192.168.124.5:9093    ## 绑定发布订阅的端口。修改:宿主机IP
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181,zoo2:2181,zoo3:2181"
    volumes:
      - "./kafka/kafka1/docker.sock:/var/run/docker.sock"
      - "./kafka/kafka1/data/:/kafka"
    networks:
      - docker_net


  kafka2:
    image: wurstmeister/kafka
    restart: unless-stopped
    container_name: kafka2
    ports:
      - "9094:9092"
    external_links:
      - zoo1
      - zoo2
      - zoo3
    environment:
      KAFKA_BROKER_ID: 2
      KAFKA_ADVERTISED_HOST_NAME: 192.168.124.5                 ## 修改:宿主机IP
      KAFKA_ADVERTISED_PORT: 9094                               ## 修改:宿主机映射port
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://192.168.124.5:9094   ## 修改:宿主机IP
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181,zoo2:2181,zoo3:2181"
    volumes:
      - "./kafka/kafka2/docker.sock:/var/run/docker.sock"
      - "./kafka/kafka2/data/:/kafka"
    networks:
      - docker_net

  kafka3:
    image: wurstmeister/kafka
    restart: unless-stopped
    container_name: kafka3
    ports:
      - "9095:9092"
    external_links:
      - zoo1
      - zoo2
      - zoo3
    environment:
      KAFKA_BROKER_ID: 3
      KAFKA_ADVERTISED_HOST_NAME: 192.168.124.5                 ## 修改:宿主机IP
      KAFKA_ADVERTISED_PORT: 9095                              ## 修改:宿主机映射port
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://192.168.124.5:9095   ## 修改:宿主机IP
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181,zoo2:2181,zoo3:2181"
    volumes:
      - "./kafka/kafka3/docker.sock:/var/run/docker.sock"
      - "./kafka/kafka3/data/:/kafka"
    networks:
      - docker_net

  kafka-manager:
    image: sheepkiller/kafka-manager:latest
    restart: unless-stopped
    container_name: kafka-manager
    hostname: kafka-manager
    ports:
      - "9000:9000"
    links:            # 连接本compose文件创建的container
      - kafka1
      - kafka2
      - kafka3
    external_links:   # 连接本compose文件以外的container
      - zoo1
      - zoo2
      - zoo3
    environment:
      ZK_HOSTS: zoo1:2181,zoo2:2181,zoo3:2181                 ## 修改:宿主机IP
      TZ: CST-8
    networks:
      - docker_net
```
执行以下命令启动

```bash
docker-compose -f docker-compose-kafka-cluster.yml up -d
```

可以看到kafka集群已经启动成功。

# 4. Kafka初认识

## 4.1 可视化管理

细心的小伙伴发现上边的配置除了kafka外还有一个kafka-manager模块。它是kafka的可视化管理模块。因为kafka的元数据、配置信息由Zookeeper管理，这里我们在UI页面做下相关配置。

*1.* 访问 [http:localhost:9000](http:localhost:9000),按图示添加相关配置

![](https://gitee.com/idea360/oss/raw/master/images/kafka-manage-config-cluster.png)

*2.* 配置后我们可以看到默认有一个topic(__consumer_offsets)，3个brokers。该topic分50个partition，用于记录kafka的消费偏移量。

![](https://gitee.com/idea360/oss/raw/master/images/kafka-cluster-default-topic.png)

## 4.2 Zookeeper在kafka环境中做了什么

*1.* 首先观察下根目录

kafka基于zookeeper，kafka启动会将元数据保存在zookeeper中。查看zookeeper节点目录，会发现多了很多和kafka相关的目录。结果如下:

```docker
➜  docker zkCli -server 127.0.0.1:2183
Connecting to 127.0.0.1:2183
Welcome to ZooKeeper!
JLine support is enabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: 127.0.0.1:2183(CONNECTED) 0] ls /
[cluster, controller, brokers, zookeeper, admin, isr_change_notification, log_dir_event_notification, controller_epoch, zk-test0000000000, kafka-manager, consumers, latest_producer_id_block, config]
```

*2.* 查看我们映射的kafka目录，新版本的kafka偏移量不再存储在zk中，而是在kafka自己的环境中。

我们节选了部分目录(包含2个partition)

```text
├── kafka1
│   ├── data
│   │   └── kafka-logs-c4e2e9edc235
│   │       ├── __consumer_offsets-1
│   │       │   ├── 00000000000000000000.index       // segment索引文件
│   │       │   ├── 00000000000000000000.log         // 数据文件
│   │       │   ├── 00000000000000000000.timeindex   // 消息时间戳索引文件
│   │       │   └── leader-epoch-checkpoint
...
│   │       ├── __consumer_offsets-7
│   │       │   ├── 00000000000000000000.index
│   │       │   ├── 00000000000000000000.log
│   │       │   ├── 00000000000000000000.timeindex
│   │       │   └── leader-epoch-checkpoint
│   │       ├── cleaner-offset-checkpoint
│   │       ├── log-start-offset-checkpoint
│   │       ├── meta.properties
│   │       ├── recovery-point-offset-checkpoint
│   │       └── replication-offset-checkpoint
│   └── docker.sock
```

结果与Kafka-Manage显示结果一致。图示的文件是一个Segment，00000000000000000000.log表示offset从0开始，随着数据不断的增加，会有多个Segment文件。

# 5. 生产与消费

## 5.1 创建主题

```bash
➜  docker docker exec -it kafka1 /bin/bash   # 进入容器
bash-4.4# cd /opt/kafka/   # 进入安装目录
bash-4.4# ./bin/kafka-topics.sh --list --zookeeper zoo1:2181,zoo2:2181,zoo3:2181   # 查看主题列表
__consumer_offsets
bash-4.4# ./bin/kafka-topics.sh --create --zookeeper zoo1:2181,zoo2:2181,zoo3:2181 --replication-factor 2 --partitions 3 --topic test    # 新建主题
Created topic test.
```

> 说明: 
> --replication-factor副本数;
> --partitions分区数;
> replication<=broker(一定);
> 有效消费者数<=partitions分区数(一定);

新建主题后, 再次查看映射目录, 由图可见，partition在3个broker上均匀分布。

![](https://gitee.com/idea360/oss/raw/master/images/kafka-cluster-topic-test-partition-show.png)


## 5.2 生产消息

```bash
bash-4.4# ./bin/kafka-console-producer.sh --broker-list kafka1:9092,kafka2:9092,kafka3:9092  --topic test
>msg1
>msg2
>msg3
>msg4
>msg5
>msg6
```


## 5.3 消费消息

```bash
bash-4.4# ./bin/kafka-console-consumer.sh --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --topic test --from-beginning
msg1
msg3
msg2
msg4
msg6
msg5
```

> --from-beginning代表从头开始消费

## 5.4 消费详情

*查看消费者组*

```bash
bash-4.4# ./bin/kafka-consumer-groups.sh --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --list
KafkaManagerOffsetCache
console-consumer-86137
```

*消费组偏移量*

```bash
bash-4.4# ./bin/kafka-consumer-groups.sh --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --describe --group KafkaManagerOffsetCache
```

*查看topic详情*

```bash
bash-4.4# ./bin/kafka-topics.sh --zookeeper zoo1:2181,zoo2:2181,zoo3:2181 --describe --topic test
Topic: test PartitionCount: 3   ReplicationFactor: 2    Configs:
    Topic: test Partition: 0    Leader: 3   Replicas: 3,1   Isr: 3,1
    Topic: test Partition: 1    Leader: 1   Replicas: 1,2   Isr: 1,2
    Topic: test Partition: 2    Leader: 2   Replicas: 2,3   Isr: 2,3
```

*查看.log数据文件*

```bash
bash-4.4# ./bin/kafka-run-class.sh kafka.tools.DumpLogSegments --files /kafka/kafka-logs-c4e2e9edc235/test-0/00000000000000000000.log  --print-data-log
Dumping /kafka/kafka-logs-c4e2e9edc235/test-0/00000000000000000000.log
Starting offset: 0
baseOffset: 0 lastOffset: 0 count: 1 baseSequence: -1 lastSequence: -1 producerId: -1 producerEpoch: -1 partitionLeaderEpoch: 0 isTransactional: false isControl: false position: 0 CreateTime: 1583317546421 size: 72 magic: 2 compresscodec: NONE crc: 1454276831 isvalid: true
| offset: 0 CreateTime: 1583317546421 keysize: -1 valuesize: 4 sequence: -1 headerKeys: [] payload: msg2
baseOffset: 1 lastOffset: 1 count: 1 baseSequence: -1 lastSequence: -1 producerId: -1 producerEpoch: -1 partitionLeaderEpoch: 0 isTransactional: false isControl: false position: 72 CreateTime: 1583317550369 size: 72 magic: 2 compresscodec: NONE crc: 3578672322 isvalid: true
| offset: 1 CreateTime: 1583317550369 keysize: -1 valuesize: 4 sequence: -1 headerKeys: [] payload: msg4
baseOffset: 2 lastOffset: 2 count: 1 baseSequence: -1 lastSequence: -1 producerId: -1 producerEpoch: -1 partitionLeaderEpoch: 0 isTransactional: false isControl: false position: 144 CreateTime: 1583317554831 size: 72 magic: 2 compresscodec: NONE crc: 2727139808 isvalid: true
| offset: 2 CreateTime: 1583317554831 keysize: -1 valuesize: 4 sequence: -1 headerKeys: [] payload: msg6
```

> 这里需要看下自己的文件路径是什么，别直接copy我的哦

*查看.index索引文件*

```bash
bash-4.4# ./bin/kafka-run-class.sh kafka.tools.DumpLogSegments --files /kafka/kafka-logs-c4e2e9edc235/test-0/00000000000000000000.index
Dumping /kafka/kafka-logs-c4e2e9edc235/test-0/00000000000000000000.index
offset: 0 position: 0
```

*查看.timeindex索引文件*

```bash
bash-4.4# ./bin/kafka-run-class.sh kafka.tools.DumpLogSegments --files /kafka/kafka-logs-c4e2e9edc235/test-0/00000000000000000000.timeindex  --verify-index-only
Dumping /kafka/kafka-logs-c4e2e9edc235/test-0/00000000000000000000.timeindex
Found timestamp mismatch in :/kafka/kafka-logs-c4e2e9edc235/test-0/00000000000000000000.timeindex
  Index timestamp: 0, log timestamp: 1583317546421
```

# 6. SpringBoot集成

笔者SpringBoot版本是 `2.2.2.RELEASE`

pom.xml添加依赖

```xml
        <dependency>
            <groupId>org.springframework.kafka</groupId>
            <artifactId>spring-kafka</artifactId>
            <version>2.4.0.RELEASE</version>
        </dependency>
```

生产者配置
```java
@Configuration
public class KafkaProducerConfig {

    /**
     * producer配置
     * @return
     */
    public Map<String, Object> producerConfigs() {
        Map<String, Object> props = new HashMap<>();
        // 指定多个kafka集群多个地址 127.0.0.1:9092,127.0.0.1:9093,127.0.0.1:9094
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,"192.168.124.5:9093,192.168.124.5:9094,192.168.124.5:9095");
        // 重试次数，0为不启用重试机制
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
        // acks=0 把消息发送到kafka就认为发送成功
        // acks=1 把消息发送到kafka leader分区，并且写入磁盘就认为发送成功
        // acks=all 把消息发送到kafka leader分区，并且leader分区的副本follower对消息进行了同步就任务发送成功
        props.put(ProducerConfig.ACKS_CONFIG,"all");
        // 生产者空间不足时，send()被阻塞的时间，默认60s
        props.put(ProducerConfig.MAX_BLOCK_MS_CONFIG, 6000);
        // 控制批处理大小，单位为字节
        props.put(ProducerConfig.BATCH_SIZE_CONFIG, 4096);
        // 批量发送，延迟为1毫秒，启用该功能能有效减少生产者发送消息次数，从而提高并发量
        props.put(ProducerConfig.LINGER_MS_CONFIG, 1);
        // 生产者可以使用的总内存字节来缓冲等待发送到服务器的记录
        props.put(ProducerConfig.BUFFER_MEMORY_CONFIG, 40960);
        // 消息的最大大小限制,也就是说send的消息大小不能超过这个限制, 默认1048576(1MB)
        props.put(ProducerConfig.MAX_REQUEST_SIZE_CONFIG,1048576);
        // 客户端id
        props.put(ProducerConfig.CLIENT_ID_CONFIG,"producer.client.id.topinfo");
        // 键的序列化方式
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        // 值的序列化方式
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        // 压缩消息，支持四种类型，分别为：none、lz4、gzip、snappy，默认为none。
        // 消费者默认支持解压，所以压缩设置在生产者，消费者无需设置。
        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG,"none");
        return props;
    }

    /**
     * producer工厂配置
     * @return
     */
    public ProducerFactory<String, String> producerFactory() {
        return new DefaultKafkaProducerFactory<>(producerConfigs());
    }

    /**
     * Producer Template 配置
     */
    @Bean(name="kafkaTemplate")
    public KafkaTemplate<String, String> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }
}
```

消费者配置

```java
@Configuration
public class KafkaConsumerConfig {


    private static final String GROUP0_ID = "group0";
    private static final String GROUP1_ID = "group1";

    /**
     * 1. setAckMode: 消费者手动提交ack
     *
     * RECORD： 每处理完一条记录后提交。
     * BATCH(默认)： 每次poll一批数据后提交一次，频率取决于每次poll的调用频率。
     * TIME： 每次间隔ackTime的时间提交。
     * COUNT： 处理完poll的一批数据后并且距离上次提交处理的记录数超过了设置的ackCount就提交。
     * COUNT_TIME： TIME和COUNT中任意一条满足即提交。
     * MANUAL： 手动调用Acknowledgment.acknowledge()后，并且处理完poll的这批数据后提交。
     * MANUAL_IMMEDIATE： 手动调用Acknowledgment.acknowledge()后立即提交。
     *
     * 2. factory.setConcurrency(3);
     * 此处设置的目的在于：假设 topic test 下有 0、1、2三个 partition，Spring Boot中只有一个 @KafkaListener() 消费者订阅此 topic，此处设置并发为3，
     * 启动后 会有三个不同的消费者分别订阅 p0、p1、p2，本地实际有三个消费者线程。
     * 而 factory.setConcurrency(1); 的话 本地只有一个消费者线程， p0、p1、p2被同一个消费者订阅。
     * 由于 一个partition只能被同一个消费者组下的一个消费者订阅，对于只有一个 partition的topic，即使设置 并发为3，也只会有一个消费者，多余的消费者没有 partition可以订阅。
     *
     * 3. factory.setBatchListener(true);
     * 设置批量消费 ，每个批次数量在Kafka配置参数ConsumerConfig.MAX_POLL_RECORDS_CONFIG中配置，
     * 限制的是 一次批量接收的最大条数，而不是 等到达到最大条数才接收，这点容易被误解。
     * 实际测试时，接收是实时的，当生产者大量写入时，一次批量接收的消息数量为 配置的最大条数。
     */
    @Bean
    KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<Integer, String>> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<Integer, String>
                factory = new ConcurrentKafkaListenerContainerFactory<>();
        // 设置消费者工厂
        factory.setConsumerFactory(consumerFactory());
        // 设置为批量消费，每个批次数量在Kafka配置参数中设置ConsumerConfig.MAX_POLL_RECORDS_CONFIG
        factory.setBatchListener(true);
        // 消费者组中线程数量,消费者数量<=partition数量，即使配置的消费者数量大于partition数量，多余消费者无法消费到数据。
        factory.setConcurrency(4);
        // 拉取超时时间
        factory.getContainerProperties().setPollTimeout(3000);
        // 手动提交
        factory.getContainerProperties().setAckMode(ContainerProperties.AckMode.MANUAL_IMMEDIATE);
        return factory;
    }

    @Bean
    public ConsumerFactory<Integer, String> consumerFactory() {
        Map<String, Object> map = consumerConfigs();
        map.put(ConsumerConfig.GROUP_ID_CONFIG, GROUP0_ID);
        return new DefaultKafkaConsumerFactory<>(consumerConfigs());
    }

//    @Bean
//    KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<Integer, String>> kafkaListenerContainerFactory1() {
//        ConcurrentKafkaListenerContainerFactory<Integer, String>
//                factory = new ConcurrentKafkaListenerContainerFactory<>();
//        // 设置消费者工厂
//        factory.setConsumerFactory(consumerFactory1());
//        // 设置为批量消费，每个批次数量在Kafka配置参数中设置ConsumerConfig.MAX_POLL_RECORDS_CONFIG
//        factory.setBatchListener(true);
//        // 消费者组中线程数量,消费者数量<=partition数量，即使配置的消费者数量大于partition数量，多余消费者无法消费到数据。
//        factory.setConcurrency(3);
//        // 拉取超时时间
//        factory.getContainerProperties().setPollTimeout(3000);
//        // 手动提交
//        factory.getContainerProperties().setAckMode(ContainerProperties.AckMode.MANUAL_IMMEDIATE);
//        return factory;
//    }
//
//    public ConsumerFactory<Integer, String> consumerFactory1() {
//        Map<String, Object> map = consumerConfigs();
//        map.put(ConsumerConfig.GROUP_ID_CONFIG, GROUP1_ID);
//        return new DefaultKafkaConsumerFactory<>(consumerConfigs());
//    }

    @Bean
    public Map<String, Object> consumerConfigs() {
        Map<String, Object> props = new HashMap<>();
        // Kafka地址
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "192.168.124.5:9093,192.168.124.5:9094,192.168.124.5:9095");
        // 是否自动提交offset偏移量(默认true)
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
        // 批量消费
        props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, "100");
        // 消费者组
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "group-default");
        // 自动提交的频率(ms)
//        propsMap.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, "100");
        // Session超时设置
        props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, "15000");
        // 键的反序列化方式
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        // 值的反序列化方式
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        // offset偏移量规则设置：
        // (1)、earliest：当各分区下有已提交的offset时，从提交的offset开始消费；无提交的offset时，从头开始消费
        // (2)、latest：当各分区下有已提交的offset时，从提交的offset开始消费；无提交的offset时，消费新产生的该分区下的数据
        // (3)、none：topic各分区都存在已提交的offset时，从offset后开始消费；只要有一个分区不存在已提交的offset，则抛出异常
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "latest");
        return props;
    }

}
```

主题配置

```java
@Configuration
public class KafkaTopicConfig {

    /**
     * 定义一个KafkaAdmin的bean，可以自动检测集群中是否存在topic，不存在则创建
     */
    @Bean
    public KafkaAdmin kafkaAdmin() {
        Map<String, Object> configs = new HashMap<>();
        // 指定多个kafka集群多个地址，例如：192.168.2.11,9092,192.168.2.12:9092,192.168.2.13:9092
        configs.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG,"192.168.124.5:9093,192.168.124.5:9094,192.168.124.5:9095");
        return new KafkaAdmin(configs);
    }

    /**
     * 创建 Topic
     */
    @Bean
    public NewTopic topicinfo() {
        // 创建topic，需要指定创建的topic的"名称"、"分区数"、"副本数量(副本数数目设置要小于Broker数量)"
        return new NewTopic("test", 3, (short) 2);
    }

}
```

消费者服务

```java
@Slf4j
@Service
public class KafkaConsumerService {


//    /**
//     * 单条消费
//     * @param message
//     */
//    @KafkaListener(id = "id0", topics = {Constant.TOPIC}, containerFactory="kafkaListenerContainerFactory")
//    public void kafkaListener0(String message){
//        log.info("consumer:group0 --> message:{}", message);
//    }
//
//    @KafkaListener(id = "id1", topics = {Constant.TOPIC}, groupId = "group1")
//    public void kafkaListener1(String message){
//        log.info("consumer:group1 --> message:{}", message);
//    }
//    /**
//     * 监听某个 Topic 的某个分区示例,也可以监听多个 Topic 的分区
//     * 为什么找不到group2呢？
//     * @param message
//     */
//    @KafkaListener(id = "id2", groupId = "group2", topicPartitions = { @TopicPartition(topic = Constant.TOPIC, partitions = { "0" }) })
//    public void kafkaListener2(String message) {
//        log.info("consumer:group2 --> message:{}", message);
//    }
//
//    /**
//     * 获取监听的 topic 消息头中的元数据
//     * @param message
//     * @param topic
//     * @param key
//     */
//    @KafkaListener(id = "id3", topics = Constant.TOPIC, groupId = "group3")
//    public void kafkaListener(@Payload String message,
//                              @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
//                              @Header(KafkaHeaders.RECEIVED_PARTITION_ID) String partition,
//                              @Header(KafkaHeaders.RECEIVED_MESSAGE_KEY) String key) {
//        Long threadId = Thread.currentThread().getId();
//        log.info("consumer:group3 --> message:{}, topic:{}, partition:{}, key:{}, threadId:{}", message, topic, partition, key, threadId);
//    }
//
//    /**
//     * 监听 topic 进行批量消费
//     * @param messages
//     */
//    @KafkaListener(id = "id4", topics = Constant.TOPIC, groupId = "group4")
//    public void kafkaListener(List<String> messages) {
//        for(String msg:messages){
//            log.info("consumer:group4 --> message:{}", msg);
//        }
//    }
//
//    /**
//     * 监听topic并手动提交偏移量
//     * @param messages
//     * @param acknowledgment
//     */
//    @KafkaListener(id = "id5", topics = Constant.TOPIC,groupId = "group5")
//    public void kafkaListener(List<String> messages, Acknowledgment acknowledgment) {
//        for(String msg:messages){
//            log.info("consumer:group5 --> message:{}", msg);
//        }
//        // 触发提交offset偏移量
//        acknowledgment.acknowledge();
//    }
//
//    /**
//     * 模糊匹配多个 Topic
//     * @param message
//     */
//    @KafkaListener(id = "id6", topicPattern = "test.*",groupId = "group6")
//    public void annoListener2(String message) {
//        log.error("consumer:group6 --> message:{}", message);
//    }

    /**
     * 完整consumer
     * @return
     */
    @KafkaListener(id = "id7", topics = {Constant.TOPIC}, groupId = "group7")
    public boolean consumer4(List<ConsumerRecord<?, ?>> data) {
        for (int i=0; i<data.size(); i++) {
            ConsumerRecord<?, ?> record = data.get(i);
            Optional<?> kafkaMessage = Optional.ofNullable(record.value());

            Long threadId = Thread.currentThread().getId();
            if (kafkaMessage.isPresent()) {
                Object message = kafkaMessage.get();
                log.info("consumer:group7 --> message:{}, topic:{}, partition:{}, key:{}, offset:{}, threadId:{}", message.toString(), record.topic(), record.partition(), record.key(), record.offset(), threadId);
            }
        }

        return true;
    }

}
```

生产者服务

```java
@Service
public class KafkaProducerService {

    @Autowired
    private KafkaTemplate kafkaTemplate;

    /**
     * producer 同步方式发送数据
     * @param topic    topic名称
     * @param key      一般用业务id，相同业务在同一partition保证消费顺序
     * @param message  producer发送的数据
     */
    public void sendMessageSync(String topic, String key, String message) throws InterruptedException, ExecutionException, TimeoutException {
        // 默认轮询partition
        kafkaTemplate.send(topic, message).get(10, TimeUnit.SECONDS);
//        // 根据key进行hash运算，再将运算结果写入到不同partition
//        kafkaTemplate.send(topic, key, message).get(10, TimeUnit.SECONDS);
//        // 第二个参数为partition,当partition和key同时设置时partition优先。
//        kafkaTemplate.send(topic, 0, key, message);
//        // 组装消息
//        Message msg = MessageBuilder.withPayload("Send Message(payload,headers) Test")
//                .setHeader(KafkaHeaders.MESSAGE_KEY, key)
//                .setHeader(KafkaHeaders.TOPIC, topic)
//                .setHeader(KafkaHeaders.PREFIX,"kafka_")
//                .build();
//        kafkaTemplate.send(msg).get(10, TimeUnit.SECONDS);
//        // 组装消息
//        ProducerRecord<String, String> producerRecord = new ProducerRecord<>("test", "Send ProducerRecord(topic,value) Test");
//        kafkaTemplate.send(producerRecord).get(10, TimeUnit.SECONDS);
    }

    /**
     * producer 异步方式发送数据
     * @param topic    topic名称
     * @param message  producer发送的数据
     */
    public void sendMessageAsync(String topic, String message) {
        ListenableFuture<SendResult<Integer, String>> future = kafkaTemplate.send(topic, message);

        // 设置异步发送消息获取发送结果后执行的动作
        ListenableFutureCallback listenableFutureCallback = new ListenableFutureCallback<SendResult<Integer, String>>() {
            @Override
            public void onSuccess(SendResult<Integer, String> result) {
                System.out.println("success");
            }

            @Override
            public void onFailure(Throwable ex) {
                System.out.println("failure");
            }
        };

        // 将listenableFutureCallback与异步发送消息对象绑定
        future.addCallback(listenableFutureCallback);
    }

    public void test(String topic, Integer partition, String key, String message) throws InterruptedException, ExecutionException, TimeoutException {
        kafkaTemplate.send(topic, partition, key, message).get(10, TimeUnit.SECONDS);
    }
}
```

web测试

```java
@RestController
public class KafkaProducerController {

    @Autowired
    private KafkaProducerService producerService;

    @GetMapping("/sync")
    public void sendMessageSync(@RequestParam String topic) throws InterruptedException, ExecutionException, TimeoutException {
        producerService.sendMessageSync(topic, null, "同步发送消息测试");
    }

    @GetMapping("/async")
    public void sendMessageAsync(){
        producerService.sendMessageAsync("test","异步发送消息测试");
    }

    @GetMapping("/test")
    public void test(@RequestParam String topic, @RequestParam(required = false) Integer partition, @RequestParam(required = false) String key, @RequestParam String message) throws InterruptedException, ExecutionException, TimeoutException {
        producerService.test(topic, partition, key, message);
    }

}
```

# 7. AD

如果您觉得写的还不错，请关注公众号 【当我遇上你】, 您的支持是我最大的动力。

![](https://gitee.com/idea360/oss/raw/master/images/wechat-qr-code.png)