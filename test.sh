#!/bin/bash
#安装apach并启动
web(){
	yum -y install httpd &>/dev/null &&  systemctl start httpd 
}
#yum安装mysql
yummysql(){
	firewalld
	wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
	rpm -ivh mysql80-community-release-el7-3.noarch.rpm
	yum -y install yum-utils
	yum install -y mysql-community-server
	systemctl start mysqld && systemctl enable mysqld
	#修改密码
	grep password /var/log/mysqld.log  >/var/log/mima.txt 
	mima=`cat /vat/log/mima.txt |awk -F ":" 'NR==1{print $4}' /var/log/mima.txt`
	
	mysqladmin -u root -p'mima' password 'QianFeng@123' && echo $?>/dev/null	
	if [ "-eq" == "0" ];then
		read -p "密码更改成功，mysql登录密码为11"
	else
		read -p "安装失败"
	fi
	#过滤出来密码，修改密码	
	
}
bymysql(){
	firewalld
	#清理安装环境
	yum erase mariadb mariadb-server mariadb-libs mariadb-devel -y
	userdel -r mysql && rm -rf /etc/my*  && rm -rf /var/lib/mysql
	#安装前的准备
	useradd -r mysql -M -s /bin/false 
	wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-boost-5.7.27.tar.gz
	yum -y install ncurses ncurses-devel openssl-devel bison gcc gcc-c++ make cmake
	mkdir -p /usr/local/{data,mysql,log}
	tar xzvf mysql-boost-5.7.27.tar.gz -C /usr/local/
	cd /usr/local/mysql-5.7.27/ 
	 cmake . \
-DWITH_BOOST=boost/boost_1_59_0/ \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DSYSCONFDIR=/etc \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DINSTALL_MANDIR=/usr/share/man \
-DMYSQL_TCP_PORT=3306 \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_READLINE=1 \
-DWITH_SSL=system \
-DWITH_EMBEDDED_SERVER=1 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1	
	make && make install
	cd /usr/local/mysql
	chown -R mysql.mysql .
	./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data  >/usr/local/mima.txt
	#过滤并保存密码
	mima2=`cat /vat/log/mima.txt | grep "for root@localhost"|awk -F ":" 'NR==1{print $2}'`
	cat> /etc/my.cnf <<EOF
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8

[mysqld]
port = 3306
user = mysql
basedir = /usr/local/mysql  
datadir = /usr/local/mysql/data  
socket = /tmp/mysql.sock
character_set_server = utf8
EOF
	startmysql
	mysqladmin -u root -p'mima2' password 'QianFeng@123' && echo $?>/dev/null	
	if [ "-eq" == "0" ];then
		read -p "密码更改成功，mysql登录密码为11"
	else
		read -p "安装失败"
	fi
		
}
startmysql(){
		cd /usr/local/mysql
		./bin/mysqld_safe --user=mysql &
}


pass(){
	echo "$num" |passwd --stdin $name
}


aliyun(){
	mkdir /etc/yum.repos.d/back
	mv /etc/yum.repos.d/*.repo  /etc/yum.repos.d/back
	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo &>/dev/null
	curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo &>/dev/null
}
	
qhyun(){
touch /etc/yum.repos.d/qinghua.repo
cat> /etc/yum.repos.d/qinghua.repo <<EOF
[base]
name=CentOS-$releasever - Base
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-$releasever - Updates
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
}

yum1(){
	yum -y install vim && yum -y install wget && yum -y install unzip && yum -y install bash-completion
}



firewalld(){
	systemctl disable firewalld && setenforce 0
	sed -r -i 's/enforcing/disabled/g' /etc/sysconfig/selinux
}

homename(){
	homenamectl set-hostname $name && init 6
}
#固定ip
ip(){
	cp /etc/sysconfig/network-scripts/ifcfg-ens33  /etc/sysconfig/network-scripts/ifcfg-ens33.bak
	cat> /etc/sysconfig/network-scripts/ifcfg-ens33 <<EOF
	TYPE="Ethernet"
	BOOTPROTO="none"
	DEVICE="ens33"
	ONBOOT="yes"
	IPADDR=192.168.92.101
	GATEWAY=192.168.92.2
	PREFIX=24
	DNS1=114.114.114.114
EOF
	systemctl restart network
}
#基于ip的虚拟主机
ip_web(){
cat > /etc/httpd/conf.d/ip.conf <<EOF
<VirtualHost 192.168.92.101:80>
DocumentRoot /name1
ServerName www.wowo.com
<Directory "/name1/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>


<VirtualHost 192.168.92.110:80>
DocumentRoot /name2
ServerName www.momo.com
<Directory "/name2/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>
EOF

#mkdir /name1 &>/dev/null && echo "第一个测试页面：">/name1/index.html
#mkdir /name2 &>/dev/null && echo "第二个测试页面：">/name2/index.html

#cat>> /etc/hosts  <<EOF
#192.168.92.101  www.wowo.com  www.momo.com
#EOF
systemctl restart httpd
}

#基于端口的虚拟主机
port_web(){
cat> /etc/httpd/conf.d/test.conf<<EOF
listen81
listen82
<VirtualHost *:81>
  DocumentRoot /rick
  ServerName www.rick.com
<Directory "/rick/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>

<VirtualHost *:82>   
  DocumentRoot /rick
  ServerName www.rick.com
<Directory "/rick/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>
EOF
	systemctl restart httpd
}


domain_web(){
cat > /etc/httpd/conf.d/domain.conf <<EOF
<VirtualHost 192.168.92.101:80>
DocumentRoot /name1
ServerName www.wowo.com
<Directory "/name1/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>


<VirtualHost 192.168.92.101:80>
DocumentRoot /name2
ServerName www.momo.com
<Directory "/name2/">
  AllowOverride None
  Require all granted
</Directory>
</VirtualHost>
               	
EOF

mkdir /name1 &>/dev/null && echo "第一个测试页面：">/name1/index.html  
mkdir /name2 &>/dev/null && echo "第二个测试页面：">/name2/index.html  

cat>> /etc/hosts  <<EOF
192.168.92.101  www.wowo.com  www.momo.com
EOF
systemctl restart httpd

}



menu(){
cat<<EOF
     一级菜单：
  1、配置WEB服务
  2、配置MYSQL服务
  3、配置Network服务
  4、更改用户密码
  5、配置YUM源
  6、关闭并开机关闭防火墙、SeLinux
  7、清空当前内存缓存
  8、创建虚拟主机
  9、退出
EOF
}
menu1(){
cat<<EOF
	二级菜单
  1-1：安装并启动WEB服务
  1-2：停止WEB服务
  1-3：重启WEB服务
  1-4：返回上一级
EOF
}
menu2(){
cat<<EOF
	二级菜单
  2-1：安装aliyun
  2-2：安装清华云
  2-3: 安装服务
  2-4：返回上一级菜单
EOF
}
menu3(){
cat<<EOF
        二级菜单
  3-1：基于域名的虚拟主机
  3-2：基于ip的虚拟主机
  3-3: 基于端口的虚拟主机
  3-4：返回上一级菜单
EOF
}

menu4(){
cat<<EOF
        二级菜单
  4-1：安装mysql
  4-2：更改mysql密码
  4-3：登录mysql
  4-4: 停止mysql
  4-5：回上一级菜单
EOF
}

menu5(){
cat<<EOF
	三级菜单
  1、yum安装mysql
  2、编译安装mysql
  3、返回上一级
EOF
}


while :
do
	menu
	read -p "根据提示输入你的选择：" num
	clear
	if [ "$num" = "1" ];then
		while :
		do
		menu1
		read -p "根据菜单选一个你喜欢的数字：" num1
		clear
		if [ "$num1" = "1" ];then
			web && echo $? &>/dev/null
                	if [ $? = 0 ];then
                        read -p "http已安装"
                	fi
		elif [ "$num1" = "2" ];then
			systemctl stop httpd
		elif [ "$num1" = "3" ];then
			systemctl restart httpd
		else 
			break
		fi
		done
	elif [ "$num" = "2" ];then
		menu4
		read -p "请根据菜单选择：" num4
		clear
		if [ "$num4" = "1" ];then
			menu5
			read -p "请根据菜单选择你喜欢的方式安装mysql：" num5
			clear
			if [ "$num5" = "1" ];then
				yummysql
			elif [ "$num5" = "2" ];then
				bymysql
			else
				break
			fi
		fi		
		if [ "$num4" = "2" ];then
		        read -p "mysql更改后密码为QianFeng@123，请输入新的密码：" mima3
			mysqladmin -uroot -p'11' password '$mima3'
			
		fi
		if [ "$num4" = "3" ];then
			read -p "请输入登录密码：" mima4
			mysql -uroot -p'$mima4'			
		fi [ "$num4" = "4" ];then
			systemctl stop mysqld
		else 
			break	
	elif [ "$num" = "3" ];then
		ip && ping -c1 -w1 www.baidu.com && echo $? &>/dev/null 
		if [ $? = 0 ];then
			echo "ip固定为：192.168.92.101"
		fi		
	elif [ "$num" = "4" ];then
		read -p "请输入密码:" num
		read -p "请输入用户名：" name
		pass && echo $?
		if [ $? = 0 ];then
		read -p "密码修改成功"
		fi
	elif [ "$num" = "5" ];then
		while :
		do
		menu2
		read -p "选择你想安装的源：" num5
		clear
		if [ "$num5" = "1" ];then
			aliyun
		elif [ "$num5" = "2" ];then
			qhyun
		elif [ "$num5" = "3" ];then
			menu2
			read -p "安装你想要的服务：" num6
			yum -y install $num6 &>/dev/null 
		else
			break	
		fi
		done
	elif [ "$num" = "6" ];then
		firewalld && echo $?
		if [ $? = 0 ];then
			read -p "防火墙已关闭"
		fi	
	elif [ "$num" = "7" ];then	
		 echo 3 > /proc/sys/vm/drop_caches && echo $?
		if [ $? = 0 ];then
			read -p  "已清除缓存"
		fi
	elif [ "$num" = "8" ];then
		while :
		do
		menu3
		read -p "根据菜单进行选择"  num8
		clear
		if [ "$num8" = "1" ];then
			firewalld
			domain_web
			curl -I  www.momo.com  &>/dev/null 
			curl -I www.wowo.com  &>/dev/null
			if [ $? = 0 ];then
				read -p "基于域名的主机配置成功,回车返回菜单"
			fi
		
 		elif [ $num8 = 2 ];then
			firewalld
			ip_web
		elif [ $num8 = 3 ];then
			firewalld
			port_web	
		else
			break
		fi
		done 			
	else
		break
	fi
	
done
