#!/usr/bin/env bash
#Blog:https://maobuni.com/

Green="\033[32m"
Font="\033[0m"
Red="\033[31m" 

#检查root权限
root_need(){
    if [ `id -u` -ne 0 ]; then
        echo -e "${Red}Error:This script must be run as root!${Font}"
        exit 1
    fi
}

#检测是否为ovz虚拟化
ovz_no(){
    if [[ -d "/proc/vz" ]]; then
        echo -e "${Red}Your VPS is based on OpenVZ，not supported!${Font}"
        exit 1
    fi
}

add_swap(){
echo -e "${Green}请输入需要添加的swap，建议为内存的2倍！${Font}"
read -p "请输入swap数值(单位MB):" swapsize

#检查是否存在swapfile
grep -q "swapfile" /etc/fstab

#如果不存在将创建swap
if [ $? -ne 0 ]; then
	echo -e "${Green}swapfile未发现，正在为其创建swapfile${Font}"
	fallocate -l ${swapsize}M /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo '/swapfile none swap defaults 0 0' >> /etc/fstab
         echo -e "${Green}swap创建成功，并查看信息：${Font}"
         cat /proc/swaps
         cat /proc/meminfo | grep Swap
else
	echo -e "${Red}swapfile已存在，swap设置失败，请先运行脚本删除swap后重新设置！${Font}"
fi
}

del_swap(){
#检查是否存在swapfile
grep -q "swapfile" /etc/fstab

#如果存在就将其移除
if [ $? -eq 0 ]; then
	echo -e "${Green}swapfile已发现，正在将其移除...${Font}"
	sed -i '/swapfile/d' /etc/fstab
	echo "3" > /proc/sys/vm/drop_caches
	swapoff -a
	rm -f /swapfile
    echo -e "${Green}swap已删除！${Font}"
else
	echo -e "${Red}swapfile未发现，swap删除失败！${Font}"
fi
}

#开始菜单
main(){
root_need
ovz_no
clear
echo -e "————————————————————内存不够，swap来凑———————————————————"
echo -e "${Green}Linux VPS一键添加/删除swap脚本${Font}"
echo -e "${Green}1、添加swap${Font}"
echo -e "${Green}2、删除swap${Font}"
echo -e "———————————————————————————————————————"
read -p "请输入数字 [1-2]:" num
if [ $num == 1 ]
then
  add_swap
elif [ $num == 2 ]
then
  del_swap
else
  echo "重新输入数字"
  main
}
main
