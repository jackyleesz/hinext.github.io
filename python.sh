#!/bin/bash  
#  
#  Author: hyxc  
#  
##########################安装依赖包#  
yum -y install python-devel openssl-devel gcc gcc-c++ sqlite-devel readline-devel ncurses-devel bzip2-devel tk-devel  
##########################下载python源码包#  
cd /usr/src/  
wget https://www.python.org/ftp/python/2.7.5/Python-2.7.5.tgz  
#########################编译安装python#  
tar zxvf Python-2.7.5.tgz  
cd Python-2.7.5  
./configure --prefix=/usr/local/python2.7.5  
make  
make install  
#######################替换之前python#  
mv /usr/bin/python /usr/bin/python.bak  
ln -s /usr/local/python2.7.5/bin/python2.7 /usr/bin/python  
echo 'export PATH=$PATH:/usr/local/python2.7.5/bin/' >> /etc/profile  
source /etc/profile  
sed -i 's/#!\/usr\/bin\/python/#!\/usr\/bin\/python2.6/' /usr/bin/yum