FROM docker.io/centos:7

MAINTAINER zhangxin <zhangxin@powerun.org.cn>

#安装nginx

COPY nginx.repo /etc/yum.repos.d/ && yum -y install nginx

#安装php

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm &&yum -y install --skip-broken php72w*


#安装crond
#RUN yum -y install crontabs
#RUN echo "*/1 * * * * php /var/www/html/Src_XuanNiaoCollege/app/console util:xapi:run CheckPodStatementJob" > /var/spool/cron/root

#安装supervisor
RUN yum install -y python-setuptools
RUN easy_install supervisor


EXPOSE 80 443
ADD supervisor.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord"]
