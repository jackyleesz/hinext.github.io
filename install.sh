#!/bin/bash
#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }


install_ServerSpeeder(){
	clear
	echo
	echo "#############################################################"
	echo "#              One click Install ServerSpeeder              #"
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

	
install_centos_ssr(){
	cd /root
	Get_Dist_Version
	if [ $Version == "7" ]; then
		wget --no-check-certificate https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
		rpm -ivh epel-release-latest-7.noarch.rpm	
	else
		wget --no-check-certificate https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
		rpm -ivh epel-release-latest-6.noarch.rpm
	fi
	yum -y install git gcc lsof python-devel libffi-devel openssl-devel ntpdate iptables
	yum -y groupinstall "Development Tools" 
	yum -y install python-setuptools && easy_install pip==9.0.1
	
	pip install cymysql==0.9.4

	wget --no-check-certificate https://download.libsodium.org/libsodium/releases/libsodium-1.0.13.tar.gz
	tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	
	#clone shadowsocks
	cd /root
	git clone -b master https://github.com/hinext/shadowsocks.git

	cd /root/shadowsocks


}
install_ubuntu_ssr(){
	apt-get -y install git wget python-setuptools build-essential  vim
	easy_install pip==9.0.1
	#install libsodium	
	wget --no-check-certificate https://download.libsodium.org/libsodium/releases/libsodium-1.0.13.tar.gz
	tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	#
	cd /root
	git clone -b manyuser https://github.com/glzjin/shadowsocks.git
	cd shadowsocks
	yum -y install python-devel
	yum -y install libffi-devel
	yum -y install openssl-devel
 

}


install_node(){
	clear
	echo
	echo "#############################################################"
	echo "#              One click Install ShadowsocksR               #"
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

	cd /root/shadowsocks

	# 下载 supervisord 配置文件
	wget https://raw.githubusercontent.com/hinext/hinext.github.io/master/supervisord.conf	-O /etc/supervisord.conf	 
	wget https://raw.githubusercontent.com/hinext/hinext.github.io/master/supervisord	-O /etc/init.d/supervisord	

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
	echo "请输入正确数字 [1-3]"
	;;
esac



