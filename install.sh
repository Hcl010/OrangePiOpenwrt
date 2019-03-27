#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
op='Openwrt'

# Root
[[ $(id -u) != 0 ]] && echo -e "\n 哎呀……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="wget"
#判断平台是否正确
sys_bit=$(uname -n)

#if [[ $sys_bit != "amlogic" ]]; then
#	echo -e " 
#	哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}
#	备注: 仅支持 N1 的Armbian 系统
#	" && exit 1
#fi

#检测内核
sys_kernel=$(uname -r)

if [[ $sys_kernel == "3.14.29" ]]; then
	echo -e "${red}即将更新内核 请稍后...${none}"
	echo 
	wget https://github.com/bettermanbao/docker-gateway/raw/master/ipset.tar.gz
	tar zxvf ipset.tar.gz -C /lib/modules/3.14.29/kernel/net/netfilter
	depmod -a
	echo -e "${green}内核更新完毕${none}"
	echo
fi

#config and run

echo -e "${yellow}设置docker的网络环境${none}"
echo

ip link set wlan0 promisc on
modprobe pppoe

subnet=$(route | grep '255.255.255.0' | awk 'NR==1 {print $1}')

if [[ $subnet != "" ]]; then
	echo -e "${green}已经检测到您的子网为：${subnet}${none}"
fi

gateway_prefix=${subnet%.*}"."

read -p "请输入你的网关的最后一位 ${gateway_prefix}" gateway_afterfix
gateway=$gateway_prefix$gateway_afterfix

cid=$(docker ps --filter ancestor=kanshudj/n1-openwrtgateway | awk 'NR > 1 {print $1}')

if [[ $cid != "" ]]; then
	echo -e "${red}检测到已经存在相同镜像的容器 是否删除已经存在的容器？${none}"
	read -p "请输入 [Y/N]" yy
	if [[ $yy != "Y" ]]; then
		echo -e "${red}开始删除${none}"
		docker stop $cid
		docker rm $cid
		echo -e "${green}成功删除${none}"
	elif [[ $yy != "N" ]]; then
		echo -e "${green}即将退出出安装${none}" && exit 1
	fi
	
fi

echo -e "${green}开始安装新的镜像${none}"

docker network create -d macvlan --subnet=$subnet/24 --gateway=$gateway -o parent=wlan0 macnet

docker pull kanshudj/n1-openwrtgateway

docker run --restart always -d --network macnet --privileged kanshudj/n1-openwrtgateway /sbin/init

echo -e "${green}安装成功${none}"

ncid=$(docker ps --filter ancestor=kanshudj/n1-openwrtgateway | awk 'NR > 1 {print $1}')


read -p "请设定openwrt的IP的最后一位 不要和网关相同 ${gateway_prefix}" op_afterfix
opip=$gateway_prefix$op_afterfix
echo -e "${green}开始设定${op}的IP地址${none}"
docker exec -it $ncid uci set network.lan.ipaddr=$opip
echo -e "${green}${op}的IP地址设定成功！${none}"
echo -e "${green}开始设定${op}的网关${none}"
docker exec -it $ncid uci set network.lan.gateway=$gateway
echo -e "${green}${op}的网关设定成功！${none}"
echo -e "${green}开始设定${op}的DNS为：223.5.5.5${none}"
docker exec -it $ncid uci set network.lan.dns=223.5.5.5
docker exec -it $ncid uci commit network
docker exec -it $ncid /etc/init.d/network restart
docker exec -it $ncid reboot
echo -e "${green}${op}的DNS设定成功！${none}"
echo -e "${green}提交保存并重启${op}${none}"

echo -e "${green}现在您可以通过${opip}来访问openwrt了${none}"

