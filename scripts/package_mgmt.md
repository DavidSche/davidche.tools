# linux 常用包管理命令

## Ubuntu : apt or apt-get 

## PACKAGE MGMT >> YUM & RPM

YUM >> Communicate with Local or Online Repo

RPM >>

-----

To install Packages

$ rpm -ivh samba*

To only install packages & check the output

$ rpm -i samba

To install packages along with verbose option & check the output

$ rpm -iv samba

To install packages with verbose, hash progress and forcefully and check the ouput

$ rpm -ivh samba --force

To upgrade packages with �Verbose�,�Hash� progress and forcefully and check the output

$ rpm -Uvh samba --force

To remove the installed Packages

$ rpm -e vsftpd

To remove a packages if dependencies are their

$ rpm -e samba --nodeps

To remove multiple packages

$ rpm -e samba vsftpd mysql --nodeps

Querying the packages:

-----

To query all installed packages

$ rpm -qa

To query a particular package

$ rpm -q samba

To view the documentation of any package

$ rpm -qd vsftpd

To view the information of any package

$ rpm -qi vsftpd

To view the configuration file of the packages

$ rpm -qc vsftpd

To view the list of all files of particular package

$ rpm -ql vsftpd

To view the status of the packages

$ rpm -qs vsftpd

-----

YUM: Yellowdog Updater Modified

-----

To see the list of packages in index i.e. Repository

$ yum list

To see list of installed packages

$ yum list installed

To see list of installed particular packages for example samba

$ yum list installed samba*

To install packages

$ yum install vsftpd* samba*

To remove packages

$ yum remove vsftpd* samba*

To see the list of all groups of packages

$ yum group list

To install a particular group of packages
> Note that these groupnames are case sensitive

$ yum group install "Mail Server" -y

To remove a particular group of packages

$ yum group remove "Mail Server" -y
