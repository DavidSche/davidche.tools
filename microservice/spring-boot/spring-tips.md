# Spring Boot Tips, Tricks and Techniques

## Spring Boot Tips, Tricks and Techniques

In this article, I will show you some tips and tricks that help you in building the Spring Boot application efficiently. I hope you will find there tips and techniques that help to boost your productivity in Spring Boot development. Of course, that’s my private list of favorite features. You may find some others by yourself, for example on the Spring “How-to” Guides site.

## Table of Contents

Source Code
- Tip 1. Use a random HTTP port in tests
- Tip 2. Use @DataJpaTest to test the JPA layer
- Tip 3. Rollback transaction after each test
- Tip 4. Multiple Spring Conditions with logical "OR"
- Tip 5. Inject Maven data into an application
- Tip 6. Inject Git data into an application
- Tip 7. Insert initial non-production data
- Tip 8. Configuration properties instead of @Value
- Tip 9. Error handling with Spring MVC
- Tip 10. Ignore not existing config file
- Tip 11. Different levels of configuration
- Tip 12. Deploy Spring Boot on Kubernetes
- Tip 13. Generate a random HTTP port

I have already published all these Spring Boot tips on Twitter in a graphical form visible below. 
You may them using the #SpringBootTip hashtag. I’m a huge fan of Spring Boot. So, 
if you have suggestions or your own favorite features just ping me on Twitter (@piotr_minkowski). 
I will definitely retweet your tweet 🙂

## spring-boot-tips

## [Source Code](https://github.com/piomin/spring-boot-tips.git)

If you would like to try it by yourself, you may always take a look at my source code. 
In order to do that you need to clone my [GitHub repository](https://github.com/piomin/spring-boot-tips.git). 
Then you should execute the command ***mvn clean package spring-boot:run*** to build and run the sample application.
This application uses embedded database H2 and exposes the REST API. Of course, 
it demonstrates all the features described in this article. If you have any suggestions, don’t afraid to create a pull request!
  
### Tip 1. Use a random HTTP port in tests

Let’s begin with some Spring Boot testing tips. You should not use a static port in your Spring Boot tests. 
In order to set this option for the particular test you need to use the webEnvironment field in ***@SpringBootTest***. 
So, instead of a default **DEFINED_PORT** provide the **RANDOM_PORT** value. Then, you can inject a port number into the test with the ***@LocalServerPort*** annotation.

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class AppTest {

   @LocalServerPort
   private int port;

   @Test
   void test() {
      Assertions.assertTrue(port > 0);
   }
}
```
 
### Tip 2. Use @DataJpaTest to test the JPA layer

Typically for integration testing, you probably use ***@SpringBootTest*** to annotate the test class. 
The problem with it is that it starts the whole application context. This in turn increases the total time required for running your test. 
Instead, you may use ***@DataJpaTest*** that starts JPA components and ***@Repository*** beans. By default, 
it logs SQL queries. So, a good idea is to disable it with the showSql field. Moreover, 
if you want to include beans annotated with ***@Service*** or ***@Component*** to the test, you may use ***@Import*** annotation.

```java
@DataJpaTest(showSql = false)
@Import(TipService.class)
public class TipsControllerTest {

    @Autowired
    private TipService tipService;

    @Test
    void testFindAll() {
        List<Tip> tips = tipService.findAll();
        Assertions.assertEquals(3, tips.size());
    }

}
```

Be careful with changing test annotations, if you have multiple integration tests in your application.
Since such change modifies a global state of your application context, it may result in not reusing that context between your tests.
You can read more about it in the following article by Philip Riecks.

### Tip 3. Rollback transaction after each test

Let’s begin with an embedded, in-memory database. In general, you should rollback all changes performed during each test. 
The changes during a particular test should not have an influence on the result of another test. However, don’t try to rollback such changes manually! For example, you should not remove a new entity added during the test as shown below.

```

@Test
@Order(1)
 public void testAdd() {
     Tip tip = tipRepository.save(new Tip(null, "Tip1", "Desc1"));
     Assertions.assertNotNull(tip);
     tipRepository.deleteById(tip.getId());
 }
 
```
 
Spring Boot comes with a very handy solution for that case. You just need to annotate the test class with ***@Transactional***. 
Rollback is the default behavior in the test mode, so nothing else is required here. But remember – it works properly only on the client-side. 
If your application performs a transaction on the server-side, it will not be rolled back.

```java
@SpringBootTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@Transactional
public class TipsRepositoryTest {

    @Autowired
    private TipRepository tipRepository;

    @Test
    @Order(1)
    public void testAdd() {
        Tip tip = tipRepository.save(new Tip(null, "Tip1", "Desc1"));
        Assertions.assertNotNull(tip);
    }

    @Test
    @Order(2)
    public void testFindAll() {
        Iterable<Tip> tips = tipRepository.findAll();
        Assertions.assertEquals(0, ((List<Tip>) tips).size());
    }
}
```
 
In some cases, you won’t use an in-memory, embedded database in your tests. For example, if you have a complex data structure, 
you may want to check committed data instead of debugging if your tests fail. 
Therefore you need to use an external database, and commit data after each test. Each time you should start your tests with a cleanup.

### Tip 4. Multiple Spring Conditions with logical “OR”

What if you would like to define multiple conditions with ***@Conditional*** on a Spring bean? By default, 
Spring Boot combines all defined conditions with logical “AND”. In the example code visible below, 
a target bean would be available only if MyBean1 and MyBean2 exist and the property multipleBeans.enabled is defined.

```

@Bean
@ConditionalOnProperty("multipleBeans.enabled")
@ConditionalOnBean({MyBean1.class, MyBean2.class})
public MyBean myBean() {
   return new MyBean();
}

```
 
In order to define multiple “OR” conditions, you need to create a class that extends AnyNestedCondition, 
and put there all your conditions. Then you should use that class with @Conditional annotation as shown below.

```
public class MyBeansOrPropertyCondition extends AnyNestedCondition {

    public MyBeansOrPropertyCondition() {
        super(ConfigurationPhase.REGISTER_BEAN);
    }

    @ConditionalOnBean(MyBean1.class)
    static class MyBean1ExistsCondition {}

    @ConditionalOnBean(MyBean2.class)
    static class MyBean2ExistsCondition {}

    @ConditionalOnProperty("multipleBeans.enabled")
    static class MultipleBeansPropertyExists {}

}

@Bean
@Conditional(MyBeansOrPropertyCondition.class)
public MyBean myBean() {
   return new MyBean();
}
```

### Tip 5. Inject Maven data into an application

You may choose between two options that allow injecting Maven data into an application. Firstly, 
you can use a special placeholder with the project prefix and ***@*** delimiter in the ***application.properties*** file.

```properties
maven.app=@project.artifactId@:@project.version@
```
 
Then, you just need to inject a property into the application using ***@Value*** annotation.

```java

@SpringBootApplication
public class TipsApp {

   @Value("${maven.app}")
   private String name;
}

```

On the other hand, you may use BuildProperties bean as shown below. It stores data available in the ***build-info.properties*** file.

```java
@SpringBootApplication
public class TipsApp {

   @Autowired
   private BuildProperties buildProperties;

   @PostConstruct
   void init() {
      log.info("Maven properties: {}, {}", 
	     buildProperties.getArtifact(), 
	     buildProperties.getVersion());
   }
}
```
 
In order to generate build-info.properties you execute goal build-info provided by Spring Boot Maven Plugin.

```shell
$ mvn package spring-boot:build-info
```

### Tip 6. Inject Git data into an application

Sometimes, you may want to access Git data inside in your Spring Boot application. In order to do that, 
you first need to include git-commit-id-plugin to the Maven plugins. During the build it generates ***git.properties*** file.

```xml
<plugin>
   <groupId>pl.project13.maven</groupId>
   <artifactId>git-commit-id-plugin</artifactId>
   <configuration>
      <failOnNoGitDirectory>false</failOnNoGitDirectory>
   </configuration>
</plugin>
```

Finally, you may inject the content from the git.properties file to the application using GitProperties bean.

```java
@SpringBootApplication
public class TipsApp {

   @Autowired
   private GitProperties gitProperties;

   @PostConstruct
   void init() {
      log.info("Git properties: {}, {}", 
	     gitProperties.getCommitId(), 
	     gitProperties.getCommitTime());
   }
}
```

### Tip 7. Insert initial non-production data

Sometimes, you need to insert some data on the application startup for demo purposes. 
You can also use such an initial data set to test your application manually during development. 
In order to achieve it, you just need to put the ***data.sql*** file on the classpath. Typically, 
you will place it somewhere inside ***src/main/resources*** directory. 
Then you easily filter out such a file during a non-dev build.

```sql
insert into tip(title, description) values ('Test1', 'Desc1');
insert into tip(title, description) values ('Test2', 'Desc2');
insert into tip(title, description) values ('Test3', 'Desc3');
```

However, if you need to generate a large data set or you are just not convinced about the solution with ***data.sql*** you can insert data programmatically. 
In that case, it is important to activate the feature only in a specific profile.

```java
@Profile("demo")
@Component
public class ApplicationStartupListener implements 
      ApplicationListener<ApplicationReadyEvent> {

   @Autowired
   private TipRepository repository;

   public void onApplicationEvent(final ApplicationReadyEvent event) {
      repository.save(new Tip("Test1", "Desc1"));
      repository.save(new Tip("Test2", "Desc2"));
      repository.save(new Tip("Test3", "Desc3"));
   }
}
```

### Tip 8. Configuration properties instead of @Value

You should not use ***@Value*** for injection, if you have multiple properties with the same prefix (e.g. app). 
Instead, use ***@ConfigurationProperties*** with constructor injection. 
You can mix it with Lombok ***@AllArgsConstructor*** and ***@Getter***.

```java
@ConstructorBinding
@ConfigurationProperties("app")
@AllArgsConstructor
@Getter
@ToString
public class TipsAppProperties {
    private final String name;
    private final String version;
}

@SpringBootApplication
public class TipsApp {

    @Autowired
    private TipsAppProperties properties;
	
}
```

### Tip 9. Error handling with Spring MVC

Spring MVC Exception Handling is very important to make sure you are not sending server exceptions to the client. Currently, there are two recommended approaches when handling exceptions. In the first of them, you will use a global error handler with @ControllerAdvice and @ExceptionHandler annotations. Obviously, a good practice is to handle all the business exceptions thrown by your application and assign HTTP codes to them. By default, Spring MVC returns HTTP 500 code for an unhandled exception.

```java
@ControllerAdvice
public class TipNotFoundHandler {

    @ResponseStatus(HttpStatus.NO_CONTENT)
    @ExceptionHandler(NoSuchElementException.class)
    public void handleNotFound() {

    }
}
```

You can also handle every exception locally inside the controller method. In that case, you just need to throw ResponseStatusException with a particular HTTP code.

```
@GetMapping("/{id}")
public Tip findById(@PathVariable("   id") Long id) {
   try {
      return repository.findById(id).orElseThrow();
   } catch (NoSuchElementException e) {
      log.error("Not found", e);
      throw new ResponseStatusException(HttpStatus.NO_CONTENT);
   }
}
```

### Tip 10. Ignore not existing config file

In general, the application should not fail to start if a configuration file does not exist. 
Especially that you can set default values for the properties. Since a default behavior of the Spring application is fail to start in case of a missing configuration file, 
you need to change it. Set the ***spring.config.on-not-found*** property to ignore.

```shell
$ java -jar target/spring-boot-tips.jar \
--spring.config.additional-location=classpath:/add.properties \
--spring.config.on-not-found=ignore
```

There is another handy solution to avoid startup falure. You can use the ***optional*** keyword in the config file location as shown below.

```shell
$ java -jar target/spring-boot-tips.jar \
--spring.config.additional-location=optional:classpath:/add.properties
```

### Tip 11. Different levels of configuration

You can change the default location of the Spring configuration file with the ***spring.config.location*** property. 
The priority of property sources is determined by the order of files in the list. ***The most significant is in the end***. 
This feature allows you to define different levels of configuration starting from general settings to the most application-specific settings. 
So, let’s assume we have a global configuration file with the content visible below.

```properties
property1=Global property1
property2=Global property2
```

Also, we have an application-specific configuration file as shown below. It contains the property with the same name as the property in a global configuration file.
```properties
property1=App specific property1
```

And here’s a JUnit test that verifies that feature.

```java
@SpringBootTest(properties = {
    "spring.config.location=classpath:/global.properties,classpath:/app.properties"
})
public class TipsAppTest {

    @Value("${property1}")
    private String property1;
    @Value("${property2}")
    private String property2;

    @Test
    void testProperties() {
        Assertions.assertEquals("App specific property1", property1);
        Assertions.assertEquals("Global property2", property2);
    }
}
```

### Tip 12. Deploy Spring Boot on Kubernetes

With the Dekorate project, you don’t have to create any Kubernetes YAML manifests manually. Firstly, you need to include the io.dekorate:kubernetes-spring-starter dependency. Then you can use annotations like @KubernetesApplication to add some new parameters into the generated YAML manifest or override defaults.

```java
@SpringBootApplication
@KubernetesApplication(replicas = 2,
    envVars = { 
       @Env(name = "propertyEnv", value = "Hello from env!"),
       @Env(name = "propertyFromMap", value = "property1", configmap = "sample-configmap") 
    },
    expose = true,
    ports = @Port(name = "http", containerPort = 8080),
    labels = @Label(key = "version", value = "v1"))
@JvmOptions(server = true, xmx = 256, gc = GarbageCollector.SerialGC)
public class TipsApp {

    public static void main(String[] args) {
        SpringApplication.run(TipsApp.class, args);
    }

}
```

After that, you need to set dekorate.build and dekorate.deploy parameters to true in you Maven build command. It automatically generates manifests and deploys the Spring Boot application on Kubernetes. If you use Skaffold for deploying applications on Kubernetes you can easily integrate it with Dekorate. To read more about the details please refer to the following article.

```shell
$ mvn clean install -Ddekorate.build =true -Ddekorate.deploy=true
```

### Tip 13. Generate a random HTTP port

Finally, we may proceed to the last of the Spring Boot tips described in this article. Probably you know that feature, but I must mention it here. Spring Boot assigns a random and free port to the web application if you set server.port property to 0.

```properties
server.port=0
```

You can set a random port in a custom predefined range, e.g. 8000-8100. However, there is no guarantee that a generated port will be unassigned.

```properties
server.port=${random.int(8000,8100)}
```

Share this: