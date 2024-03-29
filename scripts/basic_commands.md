# 基本 linux 命令

-----

To check the present working directory:

Syntax: pwd

[root@localhost ~]# pwd
/root

------
To see the contents of a directory(Folder):

Syntax: ls <option> <argument>

Options:
-l : Long list including attributes
-a : All files and directories including hidden
-d : To check for a particular file or directory
-R : Recursively, to see the contents in a tree structure
-t : time stamp
-r : reverse

Examples:

-----

To list the contents of the present working directory:
# ls

[root@localhost ~]# ls
abc              che.txt    feb-6th.txt  install.log         redhat-rhel.txt
anaconda-ks.cfg  d1         file-1       install.log.syslog  sandeep.txt
cde              dec        file-1.txt   linux-1.txt         siva
centos-1.txt     Desktop    file-2       Music               Templates
centos.txt       Documents  file-3       Pictures            Videos
che              Downloads  file-6th     Public


Options: -l:

-----

To see the list of files and directories along with their attributes:
# ls -l

[root@localhost ~]# ls -l
total 124
-rw-r--r--. 1 root root     0 Feb  6 08:56 abc
-rw-------. 1 root root  2691 Jan 26 04:05 anaconda-ks.cfg
-rw-r--r--. 1 root root     0 Feb  6 08:56 centos-1.txt
drwxr-xr-x. 2 root root  4096 Jan 25 22:40 Music
drwxr-xr-x. 2 root root  4096 Jan 25 22:40 Pictures


Options: -a:

-----

To see all files and directories including hidden files and directories:
# ls -a

[root@localhost ~]# ls -a
.                .config      file-6th            Music
..               .cshrc       .gconf              .nautilus
abc              d1           .gconfd             Pictures
anaconda-ks.cfg  .dbus        .gnome2             Public
.bash_history    dec          .gnote              .pulse

Options: -d:

-----

To check if a particular file or directory is present:
# ls -d <file or directory name>

[root@localhost ~]# ls -d Public
Public

[root@localhost ~]# ls -d file-6th
file-6th


To see the attributes of a particular file or directory:
# ls -ld <file or directory name>

[root@localhost ~]# ls -ld Public
drwxr-xr-x. 2 root root 4096 Jan 25 22:40 Public

[root@localhost ~]# ls -ld file-6th
-rw-r--r--. 1 root root 0 Feb  6 09:02 file-6th


Options: -R:

-----

To see tree structure of nested directories:

# ls -R /opt/

[root@localhost ~]# ls -R /opt
/opt:
abc  rh

/opt/rh:


To see a list of all files or directories, which are starting with a particular letter:
# ls <letter>*

[root@localhost ~]# ls f*
feb-6th.txt  file-1  file-1.txt  file-2  file-3  file-6th

[root@localhost ~]# ls D*
Desktop:
Documents:
Downloads:

To check only files in the present working directory:
# ls -l | grep "^-"

[root@localhost ~]# ls -l | grep "^-"
-rw-r--r--. 1 root root     0 Feb  6 08:56 abc
-rw-------. 1 root root  2691 Jan 26 04:05 anaconda-ks.cfg
-rw-r--r--. 1 root root     5 Feb  5  2013 centos.txt

To check only directories in the present working directory:
# ls -l | grep "^d"

[root@localhost ~]# ls -l | grep "^d"
drwxr-xr-x. 2 root root  4096 Jan 25 22:40 Desktop
drwxr-xr-x. 2 root root  4096 Jan 25 22:40 Documents
drwxr-xr-x. 2 root root  4096 Jan 25 22:40 Downloads
drwxr-xr-x. 2 root root  4096 Jan 25 22:40 Music

-----

Reading, Creating files and adding data using cat command:
Syntax: cat <option> <arguments>

To create a file along with some data:
# cat > linux-admin.txt

[root@localhost ~]# cat > linux-admin.txt
Linux administration course:
Daily : 1:30 minutes
System Admin & Network Admin

Note: ctrl+d (Save and exit)

To read the contents of a file:

[root@localhost ~]# cat linux-admin.txt
Linux administration course:
Daily : 1:30 minutes
System Admin & Network Admin

To append (add) to a file:

[root@localhost ~]# cat >> linux-admin.txt
Now, I am adding the other line in the linux-admin.txt file.
**********************************************************************
To merge contents of two files into a third file:

File-1:

[root@localhost ~]# cat linux-admin.txt
Linux administration course:
Daily : 1:30 minutes
System Admin & Network Admin
Now, I am adding the other line in the linux-admin.txt file.

File-2:

[root@localhost ~]# cat feb-6th.txt
3rd line
4th line. of cat

File-3:

[root@localhost ~]# cat linux-admin.txt feb-6th.txt >> new_file.txt

[root@localhost ~]# cat new_file.txt
Linux administration course:
Daily : 1:30 minutes
System Admin & Network Admin
Now, I am adding the other line in the linux-admin.txt file.
3rd line
4th line. of cat
**********************************************************************
Creating 0 byte (empty) files using touch command:
Syntax: touch <file_name>

Creating a single file with the touch command:

[root@localhost ~]# touch file_1.txt

[root@localhost ~]# ls -lrt file_1.txt
-rw-r--r--. 1 root root 0 Feb  7 03:56 file_1.txt

Creating multiple files using the touch command:

[root@localhost ~]# touch file_2.txt file_3.txt file_4.txt

Check files status:
[root@localhost ~]# ls -l *_*.txt
-rw-r--r--. 1 root root   0 Feb  7 03:58 file_2.txt
-rw-r--r--. 1 root root   0 Feb  7 03:58 file_3.txt
-rw-r--r--. 1 root root   0 Feb  7 03:58 file_4.txt

To change the time-stamp (date and time) of a file or directory:

Syntax: touch <option> <arguments> <file or directory name>

To change to the current date and time to a file or directory:

[root@localhost ~]# ls -lrt che.txt
-rw-r--r--. 1 root root    57 Jan 27 18:43 che.txt

Now, I am changing the above mentioned file time-stamp:

[root@localhost ~]# date
Sun Feb  7 04:18:21 PST 2016

[root@localhost ~]# touch che.txt

[root@localhost ~]# ls -lrt che.txt
-rw-r--r--. 1 root root 140 Feb  7 04:18 che.txt

To change the file or directory time-stamp to past present or future:

Syntax: touch -t <yyyymmddhhmm> <file or directory name>

[root@localhost ~]# ls -lrt linux-admin.txt
-rw-r--r--. 1 root root 140 Feb  7 04:18 linux-admin.txt

[root@localhost ~]# touch -t 201302071752 linux-admin.txt

[root@localhost ~]# ls -lrt linux-admin.txt
-rw-r--r--. 1 root root 140 Feb  7  2013 linux-admin.txt

**********************************************************************

Creating Directories:
Syntax: mkdir <option> <directory name>

Creating single directory:
[root@localhost ~]# mkdir linux-tutorials

[root@localhost ~]# ls -ld linux-tutorials/
drwxr-xr-x. 2 root root 4096 Feb  7 04:34 linux-tutorials/

Creating multiple directories:
[root@localhost ~]# mkdir redhat-1 redhat-2 redhat-3 redhat-4

[root@localhost ~]# ls -ld redhat*
drwxr-xr-x. 2 root root 4096 Feb  7 04:35 redhat-1
drwxr-xr-x. 2 root root 4096 Feb  7 04:35 redhat-2
drwxr-xr-x. 2 root root 4096 Feb  7 04:35 redhat-3
drwxr-xr-x. 2 root root 4096 Feb  7 04:35 redhat-4

To create nested directories(Sub directories inside directories):

[root@localhost ~]# mkdir -p aix/hp-ux/solaris/unix/linux

[root@localhost ~]# ls -R aix
aix:
hp-ux

aix/hp-ux:
solaris

aix/hp-ux/solaris:
unix

aix/hp-ux/solaris/unix:
linux

aix/hp-ux/solaris/unix/linux:

**********************************************************************
Directory navigation:
Syntax: cd <directory name>

To go into the directory:

[root@localhost ~]# cd aix

[root@localhost aix]# pwd
/root/aix

To go back two levels or three levels in the directories:

Example:
[root@localhost linux]# pwd
/root/aix/hp-ux/solaris/unix/linux

To back one level:
[root@localhost linux]# cd ..

Check where are you now:
[root@localhost unix]# pwd
/root/aix/hp-ux/solaris/unix

Now, go back to two directories back:
[root@localhost unix]# cd ../../

To go back to the previous working directory:
[root@localhost hp-ux]# cd -
/root/aix/hp-ux/solaris/unix

To go to current logged in users home directory:
[root@localhost hp-ux]# cd
[root@localhost ~]# pwd
/root
**********************************************************************
Day -3:
-----------COPY COMMAND #cp --------------------
Copying files and directories:

Syntax: cp <option> <source> <destination>

Example: To copy a file

[root@localhost ~]# cp -pv /root/install.log /opt

To check the file has been copied or not?

[root@localhost ~]# cd /opt/

[root@localhost opt]# ls -l install.log
-rw-r--r--. 1 root root 39343 Feb 10 22:47 install.log

To copy a directory :

[root@localhost ~]# cp -prv Music /opt

[root@localhost ~]# cd /opt

[root@localhost opt]# ls
Music
**********************************************************************
-----------MOVE COMMAND #mv --------------------
mv - move or (rename) files & directories.

Syntax: mv <option> <source> <destination>

Example: To move a directory
[root@localhost ~]# mv Videos /mnt

To check directory has been moved or not?
[root@localhost ~]# cd /mnt
[root@localhost mnt]# ls -l
drwxr-xr-x. 2 root root 4096 Jan 27 05:47 Videos

Example: To move a file

[root@localhost opt]# mv anaconda-ks.cfg /mnt

To check directory has been moved or not?
[root@localhost opt]# cd /mnt
[root@localhost mnt]# ls -l anaconda-ks.cfg
-rw-------. 1 root root 2677 Feb 10 23:03 anaconda-ks.cfg

-----

Renaming Files and Directories with "mv"
Syntax: mv <old_name> <new_name>

To Rename a file:
[root@localhost mnt]# mv anaconda-ks.cfg ana.cfg

To check file has been renamed or not?
[root@localhost mnt]# ls -l
-rw-------. 1 root root 2677 Feb 10 23:03 ana.cfg

To Rename a directory:
[root@localhost ~]# mv Music songs

To check directory has been renamed or not?
[root@localhost ~]# ls -l
drwxr-xr-x. 2 root root  4096 Jan 27 05:47 songs


-----

#### 删除空目录:

Syntax: rmdir <directory_name>

To delete an empty directory
[root@localhost ~]# rmdir songs/

To check if the directory has been deleted or not?
[root@localhost ~]# ls -l songs
ls: cannot access songs: No such file or directory

> 备注: only Empty directory

-----

#### 删除文件或目录:

Syntax: rm <option> <file or directory name>

Options:
-r = recursively
-f = forcefully

Example: To delete a file

[root@localhost mnt]# ls -ld ana.cfg
-rw-------. 1 root root 2677 Feb 10 23:03 ana.cfg

[root@localhost mnt]# rm ana.cfg
rm: remove regular file `ana.cfg'? y

Example: To delete a file forcefully
[root@localhost opt]# rm -f install.log

Example : To delete a directory

[root@localhost opt]# rm -r chetan/
rm: remove directory `chetan'? y

[root@localhost opt]# rm -rf Music/

-----

### 读取文件内容:

$ cat a.txt  # # cat anaconda-ks.cfg  : Entire File

$ more a.txt

$ more anaconda-ks.cfg : Page by Page ; While reading the file, if you want to come out then press q

$ less a.txt

$ less anaconda-ks.cfg : Line by Line ; While reading the file, if you want to come out then press q

$ head a.txt

$ head anaconda-ks.cfg : By default first 10-lines; head -4 anaconda-ks.cfg

$ tail a.txt

$ tail anaconda-ks.cfg : By default last 10-lines; tail -4 anaconda-ks.cfg

$ tailf /var/log/messages : For reading continues logs

-----

Reading zip files:

# zcat a.gz
# zmore a.gz
# zless a.gz

-----

netstat -lntcp
