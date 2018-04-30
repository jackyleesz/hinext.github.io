#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 检查当前用户是否 root
if [ $(id -u) != "0" ]; then
  echo "Error: You must be root to run this script";
  exit 1;
fi


# 检查是否 CentOS
if [ "`cat /etc/redhat-release 2>/dev/null| cut -d\  -f1`" != "CentOS" ]; then
  echo "Error: The current system is not CentOS";
  exit 1;
fi

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

clear
echo "+--------------------------------------------------------------------+";
echo "|                    Shadowsocks server for CentOS                    |";
echo "+--------------------------------------------------------------------+";

# 输入节点ID
Echo_Yellow "Set the database connect port. (Default: 3306)";
read -p "Please enter: " _NODEID_;
if [ "${_NODEID_}" = "" ]; then
    _PORT_="1";
fi

# 输入数据库主机名
Echo_Yellow "Set the database hostname. (Default: 127.0.0.1)";
read -p "Please enter: " _HOSTNAME_;
if [ "${_HOSTNAME_}" = "" ]; then
    _HOSTNAME_="127.0.0.1";
fi

# 输入数据库连接端口
Echo_Yellow "Set the database connect port. (Default: 3306)";
read -p "Please enter: " _PORT_;
if [ "${_PORT_}" = "" ]; then
    _PORT_="3306";
fi

# 输入数据库名称
while [ "${_DATABASE_}" = "" ]
do
  Echo_Yellow "Set the database name.";
  read -p "Please enter: " _DATABASE_;
done

# 输入数据库用户名
while [ "${_USERNAME_}" = "" ]
do
  Echo_Yellow "Set the database username.";
  read -p "Please enter: " _USERNAME_;
done

# 输入数据库登录密码
while [ "${_PASSWORD_}" = "" ]
do
  Echo_Yellow "Set the database password.";
  read -p "Please enter: " _PASSWORD_;
done

clear
Echo_Green "Database: `Echo_Yellow "${_DATABASE_}"`";
Echo_Green "Username: `Echo_Yellow "${_USERNAME_}"`";
Echo_Green "Password: `Echo_Yellow "${_PASSWORD_}"`";
Echo_Green "Hostname: `Echo_Yellow "${_HOSTNAME_}"`";
Echo_Green "Hostname: `Echo_Yellow "${_NODEID_}"`";
echo "";
Echo_Blue "Press any key to modify...";


echo "Modify the configuration...";
sed -i "s#"_DATABASE_"#"${_DATABASE_}"#g" /root/shadowsocks/userapiconfig.py;
sed -i "s#"_USERNAME_"#"${_USERNAME_}"#g" /root/shadowsocks/userapiconfig.py;
sed -i "s#"_PASSWORD_"#"${_PASSWORD_}"#g" /root/shadowsocks/userapiconfig.py;
sed -i "s#"_HOSTNAME_"#"${_HOSTNAME_}"#g" /root/shadowsocks/userapiconfig.py;
sed -i "s#"_NODEID_"#"${_NODEID_}"#g" /root/shadowsocks/userapiconfig.py;
	
	
clear
Echo_Blue "Shadowsocks has been installed, enjoy it!";
echo "";

# 删除自身
rm -rf $0;
