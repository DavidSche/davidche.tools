# 配置aliyun国内镜像库

设置国内镜像

``` xml
<mirror>
    <id>alimaven</id>
    <name>aliyun maven</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    <mirrorOf>central</mirrorOf>
</mirror>
```

项目pom 配置

``` xml
<repositories>
    <repository>
        <id>central</id>
        <name>aliyun maven</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
        <layout>default</layout>
        <!-- 是否开启发布版构件下载 -->
        <releases>
            <enabled>true</enabled>
        </releases>
        <!-- 是否开启快照版构件下载 -->
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
    </repository>
</repositories>
```

最新Maven阿里云仓库配置



``` setting.xml
<?xml version="1.0" encoding="UTF-8"?>

<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <localRepository>D:\mvn_repo</localRepository>

  <pluginGroups>
  </pluginGroups>

  <proxies>
  </proxies>

  <servers>
  </servers>

  <!--拷贝mirrors节点下的全部内容-->
  <mirrors>
	<mirror>
		<id>aliyun-public</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun public</name>
		<url>https://maven.aliyun.com/repository/public</url>
	</mirror>

	<mirror>
		<id>aliyun-central</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun central</name>
		<url>https://maven.aliyun.com/repository/central</url>
	</mirror>

	<mirror>
		<id>aliyun-spring</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun spring</name>
		<url>https://maven.aliyun.com/repository/spring</url>
	</mirror>

	<mirror>
		<id>aliyun-spring-plugin</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun spring-plugin</name>
		<url>https://maven.aliyun.com/repository/spring-plugin</url>
	</mirror>

	<mirror>
		<id>aliyun-apache-snapshots</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun apache-snapshots</name>
		<url>https://maven.aliyun.com/repository/apache-snapshots</url>
	</mirror>

	<mirror>
		<id>aliyun-google</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun google</name>
		<url>https://maven.aliyun.com/repository/google</url>
	</mirror>

	<mirror>
		<id>aliyun-gradle-plugin</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun gradle-plugin</name>
		<url>https://maven.aliyun.com/repository/gradle-plugin</url>
	</mirror>

	<mirror>
		<id>aliyun-jcenter</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun jcenter</name>
		<url>https://maven.aliyun.com/repository/jcenter</url>
	</mirror>

	<mirror>
		<id>aliyun-releases</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun releases</name>
		<url>https://maven.aliyun.com/repository/releases</url>
	</mirror>

	<mirror>
		<id>aliyun-snapshots</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun snapshots</name>
		<url>https://maven.aliyun.com/repository/snapshots</url>
	</mirror>

	<mirror>
		<id>aliyun-grails-core</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun grails-core</name>
		<url>https://maven.aliyun.com/repository/grails-core</url>
	</mirror>

	<mirror>
		<id>aliyun-mapr-public</id>
		<mirrorOf>*</mirrorOf>
		<name>aliyun mapr-public</name>
		<url>https://maven.aliyun.com/repository/mapr-public</url>
	</mirror>
  </mirrors>

  <profiles>
  </profiles>
</settings>


```