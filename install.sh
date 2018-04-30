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



Libtest(){
	#自动选择libsodium下载节点
	GIT='raw.githubusercontent.com'
	LIB='download.libsodium.org'
	GIT_PING=`ping -c 1 -w 1 $GIT|grep time=|awk '{print $7}'|sed "s/time=//"`
	LIB_PING=`ping -c 1 -w 1 $LIB|grep time=|awk '{print $7}'|sed "s/time=//"`
	echo "$GIT_PING $GIT" > ping.pl
	echo "$LIB_PING $LIB" >> ping.pl
	libAddr=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
	if [ "$libAddr" == "$GIT" ];then
		libAddr='https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz'
	else
		libAddr='https://download.libsodium.org/libsodium/releases/libsodium-1.0.16.tar.gz'
	fi
	rm -f ping.pl		
}

Get_Dist_Version()
{
    if [ -s /usr/bin/python3 ]; then
        Version=`/usr/bin/python3 -c 'import platform; print(platform.linux_distribution()[1][0])'`
    elif [ -s /usr/bin/python2 ]; then
        Version=`/usr/bin/python2 -c 'import platform; print platform.linux_distribution()[1][0]'`
    fi
}
python_test(){
	#测速决定使用哪个源
	tsinghua='pypi.tuna.tsinghua.edu.cn'
	pypi='mirror-ord.pypi.io'
	doubanio='pypi.doubanio.com'
	pubyun='pypi.pubyun.com'	
	tsinghua_PING=`ping -c 1 -w 1 $tsinghua|grep time=|awk '{print $7}'|sed "s/time=//"`
	pypi_PING=`ping -c 1 -w 1 $pypi|grep time=|awk '{print $7}'|sed "s/time=//"`
	doubanio_PING=`ping -c 1 -w 1 $doubanio|grep time=|awk '{print $7}'|sed "s/time=//"`
	pubyun_PING=`ping -c 1 -w 1 $pubyun|grep time=|awk '{print $7}'|sed "s/time=//"`
	echo "$tsinghua_PING $tsinghua" > ping.pl
	echo "$pypi_PING $pypi" >> ping.pl
	echo "$doubanio_PING $doubanio" > ping.pl
	echo "$pubyun_PING $pubyun" >> ping.pl
	pyAddr=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
	if [ "$pyAddr" == "$tsinghua" ]; then
		pyAddr='https://pypi.tuna.tsinghua.edu.cn/simple'
	elif [ "$pyAddr" == "$pypi" ]; then
		pyAddr='https://mirror-ord.pypi.io/simple'
	elif [ "$pyAddr" == "$doubanio" ]; then
		pyAddr='http://pypi.doubanio.com/simple --trusted-host pypi.doubanio.com'
	elif [ "$pyAddr" == "$pubyun_PING" ]; then
		pyAddr='http://pypi.pubyun.com/simple --trusted-host pypi.pubyun.com'
	fi
	rm -f ping.pl
}
source_test()
{
    if [ -s /usr/bin/python3 ]; then
        answer=`/usr/bin/python3 -c 'import requests;print(requests)'`
    elif [ -s /usr/bin/python2 ]; then
        answer=`/usr/bin/python2 -c 'import requests;print(requests)'`
    fi
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
	yum -y install git gcc python-setuptools lsof lrzsz python-devel libffi-devel openssl-devel ntpdate iptables
	yum -y groupinstall "Development Tools" 
	
	#安装 pip
	
	curl -O https://bootstrap.pypa.io/get-pip.py
	python get-pip.py 
	rm -rf *.py
	
	
	pip install --upgrade pip
	Libtest
	wget --no-check-certificate $libAddr
	tar xf libsodium-1.0.16.tar.gz && cd libsodium-1.0.16
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	
	#clone shadowsocks
	cd /root
	git clone -b master https://github.com/hinext/shadowsocksmod.git

	cd /root/shadowsocks

	#安装requirements.txt
	python_test
	pip install -r requirements.txt -i $pyAddr	


	if [ $Version == "7" ]; then
		systemctl stop firewalld.service
		systemctl disable firewalld.service
		systemctl enable iptables.service
		systemctl start iptables.service
	fi
	
	#改成北京时间
    #function check_datetime(){
	#rm -rf /etc/localtime
	#ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	#ntpdate cn.pool.ntp.org
	#}
	
	
	
}
install_ubuntu_ssr(){
	apt-get -y install python python-dev python-pip python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential git ntpdate vim
	#install libsodium	
	wget --no-check-certificate $libAddr
	tar xf libsodium-1.0.16.tar.gz && cd libsodium-1.0.16
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



