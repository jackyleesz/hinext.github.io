#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 检查当前用户是否 root
if [ $(id -u) != "0" ]; then
  echo "Error: You must be root to run this script";
  exit 1;
fi



# 检查是否 CentOS
# if [ "`cat /etc/redhat-release 2>/dev/null| cut -d\  -f1`" != "CentOS" ]; then
#   echo "Error: The current system is not CentOS";
#   exit 1;
# fi

# 输出带颜色的文字
Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m";
}
Echo_Red()
{
  echo $(Color_Text "$1" "31");
}
Echo_Green()
{
  echo $(Color_Text "$1" "32");
}
Echo_Yellow()
{
  echo $(Color_Text "$1" "33");
}
Echo_Blue()
{
  echo $(Color_Text "$1" "34");
}


echo "Install tar, wget, m2crypto, python-setuptools...";
yum install tar wget m2crypto python-setuptools gcc -y
easy_install pip

echo "Git clone the shadowsocksr...";
yum install git -y
git clone -b manyuser https://github.com/glzjin/shadowsocks.git

echo "initial the shadowsocksr...";
cd shadowsocks
cp apiconfig.py userapiconfig.py
cp config.json user-config.json

yum -y install python-devel
yum -y install libffi-devel
yum -y install openssl-devel
pip install -r requirements.txt
cd



echo "Clear the iptables...";
iptables -F
service iptables save

echo "Install libsodium...";
yum -y groupinstall "Development Tools"
wget https://github.com/jedisct1/libsodium/releases/download/1.0.13/libsodium-1.0.13.tar.gz
tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
./configure && make -j2 && make install
echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
ldconfig



clear
Echo_Blue "It has been finished, enjoy it!";
echo "";
Echo_Blue "Nice Day :)";


# 删除自身
rm -rf /root/install.sh;
