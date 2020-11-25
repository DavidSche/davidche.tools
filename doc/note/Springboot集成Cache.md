# Springboot集成Cache



## Redis集群配置

**pom.xml**

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-pool2</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-cache</artifactId>
        </dependency>
        <dependency>
            <groupId>org.ehcache</groupId>
            <artifactId>ehcache</artifactId>
        </dependency>
        <dependency>
            <groupId>javax.cache</groupId>
            <artifactId>cache-api</artifactId>
        </dependency>
```

**application.yml**

```yml
spring:
  redis:
    timeout: 6000
    password: 123456
    cluster:
      max-redirects: 3 # 获取失败 最大重定向次数 
      nodes:
        - 192.168.124.5:7001
        - 192.168.124.5:7002
        - 192.168.124.5:7003
        - 192.168.124.5:7004
        - 192.168.124.5:7005
        - 192.168.124.5:7006
    lettuce:
      pool:
        max-active: 1000 #连接池最大连接数（使用负值表示没有限制）
        max-idle: 10 # 连接池中的最大空闲连接
        min-idle: 5 # 连接池中的最小空闲连接
        max-wait: -1 # 连接池最大阻塞等待时间（使用负值表示没有限制）
  cache:
    jcache:
      config: classpath:ehcache.xml
```

**RedisConfig.class**

```java
@Configuration
@AutoConfigureAfter(RedisAutoConfiguration.class)
public class RedisConfig {
    @Bean
    public RedisTemplate<String, Object> redisCacheTemplate(LettuceConnectionFactory redisConnectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        template.setConnectionFactory(redisConnectionFactory);
        return template;
    }
}
```

## Ehcache配置

**EhcacheConfig**

```java
@Configuration
@EnableCaching
public class EhcacheConfig {
}
```

**ehcache.xml**

```xml
<config
        xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
        xmlns='http://www.ehcache.org/v3'
        xmlns:jsr107='http://www.ehcache.org/v3/jsr107'>

    <service>
        <jsr107:defaults enable-statistics="true"/>
    </service>

    <!--完整配置一个缓存。areaOfCircleCache 为该缓存名称 对应@Cacheable的属性cacheNames-->
    <cache alias="defaultCache">
        <!-- 指定缓存 key 类型，对应@Cacheable的属性key -->
        <key-type>java.lang.String</key-type>
        <!-- 配置value类型 -->
        <value-type>java.lang.String</value-type>

        <!-- 缓存 ttl，单位为分钟minutes，现在设置的是2个小时。秒是seconds -->
        <expiry>
            <ttl unit="seconds">20</ttl>
        </expiry>
        <listeners>
            <listener>
                <class>com.idcmind.ants.listener.CustomCacheEventLogger</class>
                <event-firing-mode>ASYNCHRONOUS</event-firing-mode>
                <event-ordering-mode>UNORDERED</event-ordering-mode>
                <events-to-fire-on>CREATED</events-to-fire-on>
                <events-to-fire-on>UPDATED</events-to-fire-on>
                <events-to-fire-on>EXPIRED</events-to-fire-on>
                <events-to-fire-on>REMOVED</events-to-fire-on>
                <events-to-fire-on>EVICTED</events-to-fire-on>
            </listener>
        </listeners>
        <!--储存层配置-->
        <resources>
            <!-- 分配资源大小 -->
            <heap unit="entries">2000</heap>
            <offheap unit="MB">100</offheap>
        </resources>
    </cache>

    <!--这里可以配置N个 。。。。 不同的cache 根据业务情况配置-->

    <!--配置一个缓存模板-->
    <cache-template name="heap-cache">
        <expiry>
            <ttl unit="seconds">20</ttl>
        </expiry>
        <resources>
            <heap unit="entries">2000</heap>
            <offheap unit="MB">100</offheap>
        </resources>
    </cache-template>

    <!--使用缓存模板配置缓存-->
    <cache alias="local" uses-template="heap-cache" />

</config>
```

**CustomCacheEventLogger.java**

```java
public class CustomCacheEventLogger implements CacheEventListener<Object, Object> {

    private static final Logger LOG = LoggerFactory.getLogger(CustomCacheEventLogger.class);

    @Override
    public void onEvent(CacheEvent cacheEvent) {
        LOG.info("缓存监听事件 = {}, Key = {},  Old value = {}, New value = {}", cacheEvent.getType(),
                cacheEvent.getKey(), cacheEvent.getOldValue(), cacheEvent.getNewValue());
    }
}
```

**CacheService.java**

```java
@Slf4j
@Service
public class CacheService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    /**
     * 从ehcache中获取数据，如果缓存数据不存在，则从db中查询并填充ehcache
     * @param key
     * @return
     */
    @Cacheable(value = "local", key = "#key")
    public String getDataFromLocalCache(String key) {
        return null;
    }

    /**
     * 添加缓存
     * @param key
     * @param value
     * @return
     */
    @CachePut(value = "local", key = "#key")
    public String saveData2LocalCache(String key, String value) {
        log.info("缓存到[ehcache]", key, value);
        return value;
    }

    /**
     * 移除缓存
     * @param key
     */
    @CacheEvict(value = "local", key="#key")
    public void delete(String key) {

    }

    /**
     * 从redis获取数据
     * @param key
     * @return
     */
    public String getDataFromRedisCache(String key) {
        String data = redisTemplate.opsForValue().get(key);
        return data;
    }
    /**
     * 数据存储到redis
     * @param key
     * @param value
     */
    public void saveData2RedisCache(String key, String value) {
        log.info("缓存到[redis]", key, value);
        redisTemplate.opsForValue().set(key, value, 10, TimeUnit.SECONDS);
    }

    /**
     * 从db获取数据，hystrix限流
     * @param key
     * @return
     */
    public String getDataFromDB(String key) {
        return "【data】= " + key;
    }

}
```

**DataService.java**

```java
@Slf4j
@Service
public class DataService {

    @Autowired
    CacheService cacheService;

    public String getData(String key) {

        String data = null;

        // 查找一级缓存
        data = cacheService.getDataFromRedisCache(key);
        if (!StringUtils.isEmpty(data)) {
            log.info("从[redis]里获取数据: {}", data);
            return data;
        }

        // 查找二级缓存
        data = cacheService.getDataFromLocalCache(key);
        if (!StringUtils.isEmpty(data)) {
            log.info("从[ehcache]中获取数据: {}", data);
            // 更新一级缓存
            cacheService.saveData2RedisCache(key, data);
            return data;
        }

        // 查询数据库
        data = cacheService.getDataFromDB(key);
        if (!StringUtils.isEmpty(data)) {
            log.info("从[db]中获取数据: {}", data);
            // 更新一二级缓存
            cacheService.saveData2LocalCache(key, data);
            cacheService.saveData2RedisCache(key, data);
        }

        return data;
    }
}
```

## 单元测试

```java
@Slf4j
@SpringBootTest
class CacheServiceTest {

    @Autowired
    private DataService dataService;


    @Test
    void getDataFromLocalCache() throws InterruptedException {
        for (int i=0; i<10; i++) {
            String data = dataService.getData("k1");
            log.info("====================================");
            Thread.sleep(5000);
        }
    }
}
```

**结果**

```log
2020-01-18 18:40:08.025  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[db]中获取数据: 【data】= k1
2020-01-18 18:40:08.026  INFO 67416 --- [           main] com.idcmind.ants.service.CacheService    : 缓存到[ehcache]
2020-01-18 18:40:08.033  INFO 67416 --- [           main] com.idcmind.ants.service.CacheService    : 缓存到[redis]
2020-01-18 18:40:08.040  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
2020-01-18 18:40:13.046  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[redis]里获取数据: 【data】= k1
2020-01-18 18:40:13.046  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
2020-01-18 18:40:18.054  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[ehcache]中获取数据: 【data】= k1
2020-01-18 18:40:18.054  INFO 67416 --- [           main] com.idcmind.ants.service.CacheService    : 缓存到[redis]
2020-01-18 18:40:18.061  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
2020-01-18 18:40:23.070  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[redis]里获取数据: 【data】= k1
2020-01-18 18:40:23.071  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
2020-01-18 18:40:28.081  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[db]中获取数据: 【data】= k1
2020-01-18 18:40:28.081  INFO 67416 --- [           main] com.idcmind.ants.service.CacheService    : 缓存到[ehcache]
2020-01-18 18:40:28.082  INFO 67416 --- [           main] com.idcmind.ants.service.CacheService    : 缓存到[redis]
2020-01-18 18:40:28.085  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
2020-01-18 18:40:33.091  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[redis]里获取数据: 【data】= k1
2020-01-18 18:40:33.092  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
2020-01-18 18:40:38.097  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[redis]里获取数据: 【data】= k1
2020-01-18 18:40:38.097  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
2020-01-18 18:40:43.100  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[ehcache]中获取数据: 【data】= k1
2020-01-18 18:40:43.101  INFO 67416 --- [           main] com.idcmind.ants.service.CacheService    : 缓存到[redis]
2020-01-18 18:40:43.104  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
2020-01-18 18:40:48.107  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[redis]里获取数据: 【data】= k1
2020-01-18 18:40:48.107  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
2020-01-18 18:40:53.116  INFO 67416 --- [           main] com.idcmind.ants.service.DataService     : 从[db]中获取数据: 【data】= k1
2020-01-18 18:40:53.116  INFO 67416 --- [           main] com.idcmind.ants.service.CacheService    : 缓存到[ehcache]
2020-01-18 18:40:53.116  INFO 67416 --- [           main] com.idcmind.ants.service.CacheService    : 缓存到[redis]
2020-01-18 18:40:53.119  INFO 67416 --- [           main] c.idcmind.ants.service.CacheServiceTest  : ====================================
```

