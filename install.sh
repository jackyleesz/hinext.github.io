#!/bin/bash
#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }


install_ServerSpeeder(){
	clear
	echo
	echo "#############################################################"
	echo "#              One click Install ServerSpeeder               #"
	echo "#                   Author: 404found                        #"
	echo "#############################################################"
	echo
	
	#install ServerSpeeder
    wget --no-check-certificate -O appex.sh https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh && chmod +x appex.sh && bash appex.sh install

}

change_kernel(){
	clear
	echo
	echo "#############################################################"
	echo "#                 One click Change Kernel                   #"
	echo "#                   Author: 404found                        #"
	echo "#############################################################"
	echo
	
	wget -N --no-check-certificate  https://raw.githubusercontent.com/hinext/hinext.github.io/master/kernel-2.6.32-504.3.3.el6.x86_64.rpm

    rpm -ivh kernel-2.6.32-504.3.3.el6.x86_64.rpm --force
	
	reboot now
}



#自动选择libsodium下载节点
GIT='raw.githubusercontent.com'
LIB='download.libsodium.org'
GIT_PING=`ping -c 1 -w 1 $GIT|grep time=|awk '{print $7}'|sed "s/time=//"`
LIB_PING=`ping -c 1 -w 1 $LIB|grep time=|awk '{print $7}'|sed "s/time=//"`
echo "$GIT_PING $GIT" > ping.pl
echo "$LIB_PING $LIB" >> ping.pl
libAddr=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
if [ "$libAddr" == "$GIT" ];then
	libAddr='https://github.com/jedisct1/libsodium/releases/download/1.0.13/libsodium-1.0.13.tar.gz'
else
	libAddr='https://download.libsodium.org/libsodium/releases/libsodium-1.0.13.tar.gz'
fi
rm -f ping.pl

	
install_centos_ssr(){
	yum -y install wget git gcc python-setuptools groupinstall "Development Tools" 
    wget --no-check-certificate		
	curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	python get-pip.py
	
	#install libsodium	
	wget --no-check-certificate $libAddr
	tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	
	#install supervisord
	
	rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm --quiet
	yum -y install supervisor python-pip
	pip install supervisor==3.1
	chkconfig supervisord on
	
	
	#clone shadowsocks
	cd /root
	rm -rf python
	git clone -b manyuser https://github.com/glzjin/shadowsocks.git
	
	#install devel
	cd /root/shadowsocks
	yum -y install lsof lrzsz
	yum -y install python-devel
	yum -y install libffi-devel
	yum -y install openssl-devel
	#yum -y install iptables
	#systemctl stop firewalld.service
	#systemctl disable firewalld.service
	# 配置程序
    cd shadowsocks
	wget https://raw.githubusercontent.com/hinext/hinext.github.io/new_master/user-config.json	 
	wget https://raw.githubusercontent.com/hinext/hinext.github.io/new_master/userapiconfig.py
	
	
}
install_ubuntu_ssr(){
	apt-get install wget lsof build-essential python-m2crypto supervisor git -y

	#install libsodium	
	wget --no-check-certificate $libAddr
	tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	#install pip
	apt-get install python-pip -y
	pip install cymysql
	cd /root
	git clone -b manyuser https://github.com/glzjin/shadowsocks.git
	cd shadowsocks
	pip install -r requirements.txt

	# 配置程序
	wget https://raw.githubusercontent.com/hinext/hinext.github.io/new_master/user-config.json	-O /root/shadowsocks/user-config.json	 
	wget https://raw.githubusercontent.com/hinext/hinext.github.io/new_master/userapiconfig.py	-O /root/shadowsocks/userapiconfig.py
}



install_node(){
	clear
	echo
	echo "#############################################################"
	echo "#              One click Install ShadowsocksR               #"
	echo "#                   Author: 404found                        #"
	echo "#############################################################"
	echo
	#Check Root
	[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
	#check OS version
	check_sys(){
		if [[ -f /etc/redhat-release ]]; then
			release="centos"
		elif cat /etc/issue | grep -q -E -i "debian"; then
			release="debian"
		elif cat /etc/issue | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
		elif cat /proc/version | grep -q -E -i "debian"; then
			release="debian"
		elif cat /proc/version | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
	    fi
		bit=`uname -m`
	}
	install_ssr_for_each(){
		check_sys
		if [[ ${release} = "centos" ]]; then
			install_centos_ssr
		else
			install_ubuntu_ssr
		fi
	}
	# 系统优化
	sed -i '$a * hard nofile 51200\n* soft nofile 51200' /etc/security/limits.conf	
	sed -i '$a fs.file-max = 51200\nnet.core.rmem_max = 67108864\nnet.core.wmem_max = 67108864\nnet.core.netdev_max_backlog = 250000\nnet.core.somaxconn = 4096\nnet.ipv4.tcp_syncookies = 1\nnet.ipv4.tcp_tw_reuse = 1\nnet.ipv4.tcp_tw_recycle = 0\nnet.ipv4.tcp_fin_timeout = 30\nnet.ipv4.tcp_keepalive_time = 1200\nnet.ipv4.ip_local_port_range = 10000 65000\nnet.ipv4.tcp_max_syn_backlog = 8192\nnet.ipv4.tcp_max_tw_buckets = 5000\nnet.ipv4.tcp_fastopen = 3\nnet.ipv4.tcp_rmem = 4096 87380 67108864\nnet.ipv4.tcp_wmem = 4096 65536 67108864\nnet.ipv4.tcp_mtu_probing = 1' /etc/sysctl.conf
	
	install_ssr_for_each

    # modify Config	
	cd /root/shadowsocks

	
	# 启用supervisord
	echo_supervisord_conf > /etc/supervisord.conf
    sed -i '$a [program:ssr]\ncommand = python /root/shadowsocks/server.py\nuser = root\nautostart = true\nautorestart = true' /etc/supervisord.conf
	wget  --no-check-certificate https://raw.githubusercontent.com/hinext/hinext.github.io/master/supervisord -O /etc/init.d/supervisord

	#clear iptables
	iptables -F
	service iptables save
	clear
	echo "#############################################################"
	echo "#             It has been finished, enjoy it!               #"
	echo "#                     Nice Day :)                           #"
	echo "#############################################################"
}
echo
echo "#############################################################"
echo "#                  One click Install Script                 #"
echo "# Please choose the server you want                         #"
echo "# 1  change_kernel                                          #"
echo "# 2  install_ServerSpeeder                                  #"
echo "# 3  SSR One click Install                                  #"
echo "#############################################################"
echo
stty erase '^H' && read -p " 请输入数字 [1-3]:" num
case "$num" in
	1)
	change_kernel
	;;
	2)
	install_ServerSpeeder
	;;
	3)
	install_node
	;;
	*)
	echo "请输入正确数字 [1-2]"
	;;
esac
