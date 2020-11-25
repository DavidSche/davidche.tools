# SpringCloud-Gateway认证授权



基于spring cloud gateway的简易认证授权



![基于spring-cloud-gateway的简易认证授权](../assets/基于spring-cloud-gateway的简易认证授权.png)



用户的访问基本上都是需要携带 JWT Token 的，gateway-service 在接收到请求之后，会向鉴权服务发送鉴权请求，获得授权之后可以得到当前访问的用户详细信息；如果检测到请求未经授权，那么 gateway-service 直接会返回未授权错误，保护内部服务访问安全。

理论上鉴权也可以通过自定义 gateway filter 来实现，不过我们希望可以尽可能多使用 `spring-security` 提供的能力，毕竟自己封装需要实现的东西还是有点多的。

Spring Cloud Gateway 只支持搭配 webflux 使用，所以我们后续使用了 `@EnableWebFluxSecurity` 注解。

我们将 gateway 作为一个 resource server 进行配置，毕竟 `spring-security` 帮我们做了很多事情，所以需要我们自己配置的代码很少。



## api-server

资源服务器是一个普通的springboot服务，在整个微服务环境中是透明的，可以直接访问

curl http://localhost:8080/hello
Hello World.

```java
@RestController
public class ApiController {

    @GetMapping("/hello")
    public String getRequest() {
        return "Hello World.";
    }
}

```



## auth-server

pom.xml

```xml
 				<dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-oauth2</artifactId>
        </dependency>
        <dependency>
            <groupId>com.nimbusds</groupId>
            <artifactId>nimbus-jose-jwt</artifactId>
            <version>8.2</version>
        </dependency>
```

Application.yml(签名文件在resource目录下)

```yaml
server:
  port: 8081

## actuator
management:
  endpoints:
    web.exposure.include: "*"
```



认证配置

```java
@EnableAuthorizationServer
@Configuration
@AllArgsConstructor
public class AuthorizationServerConfigurer extends AuthorizationServerConfigurerAdapter {

    private final AuthenticationManager authenticationManagerBean;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        clients.inMemory()
                .withClient("test-client")
                .secret(passwordEncoder.encode("test-secret"))
                .authorizedGrantTypes("refresh_token", "password")
                .scopes("default-scope");
    }

    @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
        endpoints
                .authenticationManager(authenticationManagerBean)
                .accessTokenConverter(accessTokenConverter());
    }

    @Override
    public void configure(AuthorizationServerSecurityConfigurer security) throws Exception {
        security
                .allowFormAuthenticationForClients();
    }

    @Bean
    public AccessTokenConverter accessTokenConverter() {
        JwtAccessTokenConverter jwtAccessTokenConverter = new JwtAccessTokenConverter();
        jwtAccessTokenConverter.setKeyPair(keyPair());
        return jwtAccessTokenConverter;
    }


    @Bean
    public KeyPair keyPair() {
        KeyStoreKeyFactory keyStoreKeyFactory = new KeyStoreKeyFactory(new ClassPathResource("demojwt.jks"), "keystorepass".toCharArray());
        return keyStoreKeyFactory.getKeyPair("jwt", "keypairpass".toCharArray());
    }
}
```

安全配置

```java
@Configuration
@EnableWebSecurity
public class WebSecurityConfigurer extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .requestMatchers(EndpointRequest.toAnyEndpoint()).permitAll()
                .antMatchers("/.well-known/jwks.json").permitAll()
                .anyRequest().authenticated();
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(s -> new UserDetails() {
            @Override
            public Collection<? extends GrantedAuthority> getAuthorities() {
                return AuthorityUtils.createAuthorityList("USER");
            }

            @Override
            public String getPassword() {
                return passwordEncoder().encode("user-password");
            }

            @Override
            public String getUsername() {
                return "user-username";
            }

            @Override
            public boolean isAccountNonExpired() {
                return true;
            }

            @Override
            public boolean isAccountNonLocked() {
                return true;
            }

            @Override
            public boolean isCredentialsNonExpired() {
                return true;
            }

            @Override
            public boolean isEnabled() {
                return true;
            }
        });
    }

    @Override
    @Bean
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

}
```

controller

```java
@RestController
@AllArgsConstructor
public class MvcController {

    private final KeyPair keyPair;

    @GetMapping("/.well-known/jwks.json")
    public Map<String, Object> getKey() {
        RSAPublicKey publicKey = (RSAPublicKey) keyPair.getPublic();
        RSAKey key = new RSAKey.Builder(publicKey).build();
        return new JWKSet(key).toJSONObject();
    }
}
```



## gateway-service

Pom.xml

```xml
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-actuator</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-webflux</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.cloud</groupId>
			<artifactId>spring-cloud-starter-gateway</artifactId>
		</dependency>

		<dependency>
			<groupId>org.springframework.security</groupId>
			<artifactId>spring-security-config</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.security</groupId>
			<artifactId>spring-security-oauth2-resource-server</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.security</groupId>
			<artifactId>spring-security-oauth2-client</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.security</groupId>
			<artifactId>spring-security-oauth2-jose</artifactId>
		</dependency>
```

Application.yml

```yaml
server:
  port: 8082

## gateway
spring:
  cloud.gateway.routes:
    - id: api-service-route
      uri: http://localhost:8080
      predicates:
        - Path=/api/**
      filters:
        - StripPrefix=1
  security.oauth2.resourceserver.jwt.jwk-set-uri: 'http://localhost:8081/.well-known/jwks.json'
```

因为我们的 authorization server 使用了 jwt token，jwt 很适合在纯 RESTful API 中作为无状态的认证凭证进行使用，搭配 spring security oauth2 的话，简单且好用。当然如果在某些场景下需要撤销某个 jwt token，也可以搭配 redis 进行管理。

我们在上面代码中声明了 gateway-service 作为一个简单的 resource server 并启用了 jwt，jwt token 通过公钥来验证有效性。因此我们需要指定 jwt 鉴权的公钥地址。





ResourceServerConfigurer

```java
@EnableWebFluxSecurity
public class ResourceServerConfigurer {

    @Bean
    public SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http.authorizeExchange()
                .pathMatchers("/actuator/**").permitAll()
                .anyExchange().authenticated();

        http.oauth2ResourceServer().jwt();

        return http.build();
    }
}
```



## 测试

依次运行 auth-service，gateway-service，api-service

获取 access token
```shell script
curl -X POST \
  http://localhost:8081/oauth/token \
  -d grant_type=password \
  -d client_id=test-client \
  -d client_secret=test-secret \
  -d username=user-username \
  -d password=user-password
```

不带 token 访问接口，返回 401 Unauthorized
```shell script
curl -X GET http://localhost:8082/api/hello -sI
```

带 token 访问接口
```shell script
curl -X GET \
  http://localhost:8082/api/hello \
  -H 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NzI0ODY3ODksInVzZXJfbmFtZSI6InVzZXItdXNlcm5hbWUiLCJhdXRob3JpdGllcyI6WyJVU0VSIl0sImp0aSI6IjA3MDZmOWUyLWRlMWYtNDg4ZS1hNTJhLTUzMjdiMjU4ZTI4ZiIsImNsaWVudF9pZCI6InRlc3QtY2xpZW50Iiwic2NvcGUiOlsiZGVmYXVsdC1zY29wZSJdfQ.IqSmO7rH_lFpQ8__ZP1rwSDh5S6kw3EPaT3gs-byW_usN5iM0l0ohEV1OCb1jOUjcMoxnqUM-C3ZEND_tVdGlpscNVXT1avkVGw8Rc2Y49_Ee0OYgLwg97LOFdoHgCIEWKqronk5EdZJES1Zv95MbGSO1o6U_mo8My1-znxNgUwYpGt1sNUsaoCRzIKEQR--67IWe3EMmxo1D0IcPPi0fgKbVD2LR7mOQTqvQMHEF4LplS67mbfUWLFJg9Q4gyH0l3ndgGkCIcofPop9-GlwNCgp52RiGQlp8MCXydHbybr-_g-nXrstxSHQ-1iC0ihIMSueDhEuN7gLe5OELBW1oA'
```

经过上面这些配置之后，我们就已经实现了一个比较简单的微服务架构下的网关服务了。



## 参考

https://mp.weixin.qq.com/s/4v_wwX0SS7jvOwtO8uiDAw