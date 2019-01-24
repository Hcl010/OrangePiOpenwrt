# Orange Pi Zero Plus OpenWRT 刷入说明

准备工作：

 ·Orange Pi Zero Plus
 
 ·TF卡
 
 ·读卡器
 
 ·PC
 
所需软件：
 
 ·Win32DiskImager【windows】 或 etcher【全平台】
 
 ·浏览器
 
 具体步骤：
 
 1.下载固件(openwrt_for_orange-pi-zero-plus.zip)并解压得到(openwrt_for_orange-pi-zero-plus.img) 。
 
 2.将TF卡插入读卡器并连接至PC端；
 
 3.开启 Win32DiskImager ,选择openwrt_for_orange-pi-zero-plus.img，点击写入，即完成固件烧录步骤；
 
 4.将TF卡插入 Pi 的卡槽中，并接入到当前的局域网，microusb为供电口可用电脑的usb供电或者用手机5v充电头供电；
 
 5.打开浏览器，进入默认网关地址 http://openwrt/  密码：password 进行各项设置；
 
 6.Pi 默认的网络模式为DHCP客户端模式，你需要切换为：静态地址，ipv4地址请手动指定,ipv4网关设置为你主路由的IP地址，dns建议设置为223.5.5.5，其他默认
 
 7.如果你需要使用PI作为DHCP服务器的话，下方DHCP服务要开启，不要勾选忽略此接口，高级设置中勾选动态DHCP ipv4子网掩码 255.255.255.0 DHCP选项 设置为3,你的PI地址  和 6,你的PI地址。
 
 8.保存并应用。
