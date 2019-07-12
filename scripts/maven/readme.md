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
