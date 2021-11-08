# 清理 Docker for Windows的镜像空间

经过长时间的使用，Win10的C盘慢慢的满了，清理空间时候就看到了Docker 的镜像占用了大量的空间，就想把它删除了，同时把它移到D盘去。docker pull下来的镜像目录默认放在：C:\ProgramData\docker\windowsfilter。

解决办法
简单用三方工具搞定下，https://github.com/moby/docker-ci-zap， 注意命令行需要管理员权限
以管理员权限打开cmd，执行以下命令：

docker-ci-zap.exe  -folder "C:\ProgramData\docker\windowsfilter"

如果输出Successfully则表示删除成功，否则删除失败。

然后可以采用命令行软链接的方式将Docker文件夹链接到其他盘符
mklink /J C:\ProgramData\Docker\windowsfilter D:\ProgramData\Docker\windowsfilter

以上指令需要保证C盘文件夹windowsfilter不存在，而D盘windowsfilter 存在后进行软链接

------

docker win10 扩充容量!

2020-07-17,9点43
docker reset to default: 点开setting后点右上角的虫子.里面有reset.

2020-07-17,10点25
添加docker 磁盘空间的方法: 亲测完美.但是一定要要注意,#6里面的步奏,其实需要修改很多个
VhdSize需要都改成240即可.

https://forums.docker.com/t/manage-host-disk-volume-size/37438/2

1) Stop Docker
2) Start Powershell ISE as Administrator
3) Using the Powershell command prompt, make a backup of the file to be edited: cp C:\Program Files\Docker\Docker\Resources\MobyLinux.ps1 C:\Program Files\Docker\Docker\Resources\MobyLinux.bak
4) In Powershell ISE, open the file C:\Program Files\Docker\Docker\Resources\MobyLinux.ps1
5) Find the entry global:VhdSize (Line 86 in version 17.06.1-ce-win24 (13025))  #6) Change the first number in this lineglobal:VhdSize = 60*1024*1024*1024 # 60GB from 60 to the size you want in GB. For example, to create a 120GB volume, change the line to $global:VhdSize = 120*1024*1024*1024 # 120GB
7) In Powershell ISE, click File… Save to save the updated file.
8) In Powershell ISE, click File… Save As… and save a backup of the modified file. This file can be used to restore the customization after a re-install. To be safe, the file should not be used to re-apply the customization after an upgrade, since the file could have been changed as part of the upgrade. After upgrades, follow the steps above to re-apply customizations as necessary.
9) Restart Docker
10) From the Docker UI, select Reset… Reset to Factory Defaults. This action will rebuild your MobyLinuxVM with the new custom volume size. WARNING: this step wipes out all Images and Containers stored on the MobyLinuxVM!!!

 
