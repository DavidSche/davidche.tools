#1、查看当前文件夹下面各个文件的大小
ll -lh
#2、查看某文件夹占用总的空间大小
du -h --max-depth=1 /usr/local/
#8.0K    /usr/local/include
#275M    /usr/local/
#参数--max-depth用来指定深入目录的层数，为1就指定1层
#使用"*"，可以得到文件的使用空间大小.
#
du -h --max-depth=1 /usr/Java/jdk1.6.0_25/* 

#7.9M    /usr/java/jdk1.6.0_25/sample
#19M     /usr/java/jdk1.6.0_25/src.zip

#3、查年磁盘空间的使用空间
df -h