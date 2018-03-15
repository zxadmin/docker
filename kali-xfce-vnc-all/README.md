# kali容器安装桌面以及vncserver服务，安装渗透工具集


docker build -t kali-xfce-vnc-all:0.1 .

docker run -d -p 5911:5901 kali-xfce-vnc-all:0.1