FROM docker.io/kalilinux/kali-linux-docker:latest
MAINTAINER zhangxin <zhangxin@powerun.org.cn>

# Add Xwindows configuration
ADD .vnc /root/.vnc

# Copy startup script
ADD startup.sh /startup.sh
ADD sources.list /etc/apt/


# Run startup script
RUN apt-get clean all && apt-get update && \ 
    apt-get -y install software-properties-common  && \
    apt-get -y install kali-linux-all kali-linux-web && \
    apt-get -y install vim tightvncserver x11vnc kali-defaults kali-root-login desktop-base xfce4* && \
    sed -i "s/1024x768/1280x960/g" /usr/bin/vncserver && \
    mkdir /.vnc && \
    x11vnc -storepasswd 123456 ~/.vnc/passwd && \
    chmod 0755 /startup.sh
RUN apt-get install -y kali-linux-full && apt-get clean all


# Expose VNC
EXPOSE 5901

ENV USER root


ENTRYPOINT ["/startup.sh"]
