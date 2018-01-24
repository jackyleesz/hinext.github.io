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
		libAddr='https://github.com/jedisct1/libsodium/releases/download/1.0.13/libsodium-1.0.13.tar.gz'
	else
		libAddr='https://download.libsodium.org/libsodium/releases/libsodium-1.0.13.tar.gz'
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
	#第一次yum安装 supervisor pip
	yum -y install supervisor python-pip

	#第二次pip supervisor是否安装成功
	if [ -z "`pip`" ]; then
    curl -O https://bootstrap.pypa.io/get-pip.py
		python get-pip.py 
		rm -rf *.py
	fi
	if [ -z "`ps aux|grep supervisord|grep python`" ]; then
    pip install supervisor

	fi
	#第三次检测pip supervisor是否安装成功
	if [ -z "`pip`" ]; then
		if [ -z "`easy_install`"]; then
    wget http://peak.telecommunity.com/dist/ez_setup.py
		python ez_setup.py
		fi		
		easy_install pip
	fi
	if [ -z "`ps aux|grep supervisord|grep python`" ]; then
    easy_install supervisor

	fi
	pip install --upgrade pip
	Libtest
	wget --no-check-certificate $libAddr
	tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	
	#clone shadowsocks
	cd /root
	rm -rf python
	git clone -b manyuser https://github.com/glzjin/shadowsocks.git

	cd /root/shadowsocks
	chkconfig supervisord on
	#第一次安装
	python_test
	pip install -r requirements.txt -i $pyAddr	
	#第二次检测是否安装成功
	source_test
	if [ -z "$answer" ]; then
		pip install -r requirements.txt #用自带的源试试再装一遍
	fi
	#第三次检测是否成功
	source_test
	if [ -z "$answer" ]; then
		mkdir python && cd python
		git clone https://github.com/shazow/urllib3.git && cd urllib3
		python setup.py install && cd ..
		git clone https://github.com/nakagami/CyMySQL.git && cd CyMySQL
		python setup.py install && cd ..
		git clone https://github.com/requests/requests.git && cd requests
		python setup.py install && cd ..
		git clone https://github.com/pyca/pyopenssl.git && cd pyopenssl
		python setup.py install && cd ..
		git clone https://github.com/cedadev/ndg_httpsclient.git && cd ndg_httpsclient
		python setup.py install && cd ..
		git clone https://github.com/etingof/pyasn1.git && cd pyasn1
		python setup.py install && cd ..
		rm -rf python
	fi	
	
	if [ $Version == "7" ]; then
		systemctl stop firewalld.service
		systemctl disable firewalld.service
		systemctl enable iptables.service
		systemctl start iptables.service
	fi
		
	#配置文件
	wget	https://raw.githubusercontent.com/hinext/hinext.github.io/new_master/user-config.json	-O /root/shadowsocks/user-config.json 
	wget	https://raw.githubusercontent.com/hinext/hinext.github.io/new_master/userapiconfig.py	-O /root/shadowsocks/userapiconfig.py

}
install_ubuntu_ssr(){
	apt-get -y install python python-dev python-pip python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential git ntpdate vim
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
	
	#配置文件
	wget	https://raw.githubusercontent.com/hinext/hinext.github.io/new_master/user-config.json	-O /root/shadowsocks/user-config.json 
	wget	https://raw.githubusercontent.com/hinext/hinext.github.io/new_master/userapiconfig.py	-O /root/shadowsocks/userapiconfig.py
 
}

start_supervisord(){

supervisord

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
	
	#改成北京时间
	# function check_datetime(){
	# rm -rf /etc/localtime
	# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	# ntpdate time.windows.com
	# }

	# 系统优化
	sed -i '$a * hard nofile 51200\n* soft nofile 51200' /etc/security/limits.conf	
	sed -i '$a fs.file-max = 51200\nnet.core.rmem_max = 67108864\nnet.core.wmem_max = 67108864\nnet.core.netdev_max_backlog = 250000\nnet.core.somaxconn = 4096\nnet.ipv4.tcp_syncookies = 1\nnet.ipv4.tcp_tw_reuse = 1\nnet.ipv4.tcp_tw_recycle = 0\nnet.ipv4.tcp_fin_timeout = 30\nnet.ipv4.tcp_keepalive_time = 1200\nnet.ipv4.ip_local_port_range = 10000 65000\nnet.ipv4.tcp_max_syn_backlog = 8192\nnet.ipv4.tcp_max_tw_buckets = 5000\nnet.ipv4.tcp_fastopen = 3\nnet.ipv4.tcp_rmem = 4096 87380 67108864\nnet.ipv4.tcp_wmem = 4096 65536 67108864\nnet.ipv4.tcp_mtu_probing = 1' /etc/sysctl.conf
	
	install_ssr_for_each



	# 下载 supervisord 配置文件
	wget https://raw.githubusercontent.com/hinext/hinext.github.io/master/supervisord.conf	-O /etc/supervisord.conf	 
	wget https://raw.githubusercontent.com/hinext/hinext.github.io/master/supervisord	-O /etc/init.d/supervisord	

	#clear iptables
	iptables -F
	service iptables save
	
	echo "/usr/bin/supervisord -c /etc/supervisord.conf" >> /etc/rc.local
	chmod +x /etc/rc.d/rc.local
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
echo "# 4  Start Supervisord                                      #"
echo "#############################################################"
echo
stty erase '^H' && read -p " 请输入数字 [1-4]:" num
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
	4)
	start_supervisord
	;;
	*)
	echo "请输入正确数字 [1-4]"
	;;
esac



