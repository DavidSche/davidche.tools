# davidche.tools

tools and scripts for davidche

[registry](https://ralph.blog.imixs.com/2017/04/22/how-to-setup-a-private-docker-registry/)

------

cqjy-cloud

------

| 服务名称 | 软件 |   IP地址.   |   端口 |   标签 |   备注 |
| :------ | :------ | :-----: | :-----: | :-----: | -----: |
| 开发环境 | --- |   ---   |   --- |   ---  |    ---  |
| app-git | GitLab |   192.168.5.101  |    80 |   gitNode  |    源码 |
| app-git |  |   192.168.5.101   |    443 |   gitNode  |    源码 |
| app-git |  |   192.168.5.101   |    22 |   gitNode  |    源码 |
| app-pm | 禅道 |   192.168.5.103   |    *:280->80 |   pmNode  |    zentao项目管理  |
| app-wiki | wiki |   192.168.5.104   |    80 |   wikiNode  |    wiki管理  |
| app-ftp | FTP |   192.168.5.101   |    80 |   ftpNode  |    ftp文件管理  |
| app-ci | Jenkis |   192.168.5.104   |    *:1080->8080/tcp, *:50000->50000/tcp |   ciNode  |    CI服务  |
| --- | --- |   ---   |   --- |   ---  |    ---  |
| app-swarm | Portainer |   192.168.5.101   |    *:9000->9000/tcp |   managerNode  |    CI服务  |
| app-registry | Registry |   192.168.5.101   |    *:5000->5000/tcp |   RegistryNode  |    仓库服务  |
| app-registry | Registry-ui |   192.168.5.101   |    *:3080->80/tcp |   RegistryNode  |    仓库服务  |
| --- | --- |   ---   |   --- |   ---  |    ---  |
| db-mysql | MySQL |   192.168.5.104   |    *:3306->3306/tcp |   mysqlNode  |    Mysql DB服务  |
| db-psql | PostgreSQL |   192.168.5.104   |    *:5432->5432/tcp |   RegistryNode  |    wiki使用的postgresql服务  |
| 测试环境 | --- |   ---   |   --- |   ---  |    ---  |
| app-consul | Consul |   192.168.5.xxx   |    *:3306->3306/tcp |   mysqlNode  |    Mysql DB服务  |
| db-redis | redis |   192.168.5.xxx   |    *:3080->80/tcp |   RegistryNode  |    postgresql服务  |
| db-mysql | MySQL |   192.168.5.104   |    *:3306->3306/tcp |   mysqlNode  |    Mysql DB服务  |
| db-psql | PostgreSQL |   192.168.5.104   |    *:5432->5432/tcp |   RegistryNode  |    wiki使用的psql服务  

------
禁用 outreach 功能步骤：
1、以管理员身份登陆 Nexus
2、 打开 Administration ->  Capabilities 。
3、右击， Outreach Management 功能，点击 disable

How to Disable Outreach
Disabling this feature is a last resort.

You may decide to avoid receiving messages on your Nexus welcome page entirely. Or you know that your Nexus instance will never be able to have access to the required remote hosts.

In those cases, the outreach feature can be disabled.

Disabling Outreach in Repository Manager 3
To disable outbound Outreach requests in NXRM 3:

Signin to your NXRM instance as an Administrator.
Open Administration -> System -> Capabilities. Select the Outreach Management capability.
Click the Disable button. Your changes are immediately saved.
Disabling Outreach in Repository Manager 2
To disable outbound Outreach requests in NXRM 2:

Signin to your NXRM instance as an Administrator.
Open Administration -> Capabilities. Select the Outreach Management capability.
Uncheck the Enable checkbox. Click Save.