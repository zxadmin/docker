# 搭建docker私有仓库、自签发证书、登录认证


## 准备好基础环境

两台centos7操作系统，一台作为docker私有仓库（192.168.1.204），一台作为客户机（192.168.1.206）

主要在docker私有仓库做操作


### 均关闭selinux，关闭firewalld

[root@docker-registry ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

[root@docker-registry ~]# systemctl stop firewalld && systemctl disable firewalld

或者开放5000端口


### 注意系统时间，两台服务器时间保持一致！！！


### 安装docker以及docker-compose

[root@docker-registry ~]# yum -y install docker python-pip

[root@docker-registry ~]# pip install docker-compose


### 启动服务

[root@docker-registry ~]# systemctl start docker && systemctl enable docker


## CA证书的制作

### 配置ssl

首先将openssl.cnf文件放到/etc/pki/tls/下（覆盖源文件），必须在生成证书之前修改，否则无意义

[ v3_req ]

basicConstraints = CA:FALSE

keyUsage = nonRepudiation, digitalSignature, keyEncipherment

[ alternate_names ]

DNS.1 = registry.dockerlocal

DNS.2 = registry2.default.svc.cluster.local

DNS.3 = dockerauth.default.svc.cluster.local

IP.1 = 192.168.1.204

IP.2 = 192.168.1.231

[ v3_ca ]

subjectAltName = @alternate_names

主要是这一块地方，IP.1为私有仓库的地址，否则后面客户机连接会报错：

Error response from daemon: Get https://192.168.1.204:5000/v1/users/: x509: cannot validate certificate for 192.168.1.204 because it doesn't contain any IP SANs


### 生成自签发证书

[root@docker-registry ~]# mkdir docker-registry && cd docker-registry

[root@docker-registry ~]# openssl req -newkey rsa:2048 -nodes -sha256 -keyout server.key -x509 -days 365 -out server.cert

Generating a 2048 bit RSA private key

...........+++

.................................................................................+++

writing new private key to 'server.key'

-----

You are about to be asked to enter information that will be incorporated

into your certificate request.

What you are about to enter is what is called a Distinguished Name or a DN.

There are quite a few fields but you can leave some blank

For some fields there will be a default value,

If you enter '.', the field will be left blank.

-----

Country Name (2 letter code) [XX]:CN

State or Province Name (full name) []:docker

Locality Name (eg, city) [Default City]:beijing

Organization Name (eg, company) [Default Company Ltd]:

Organizational Unit Name (eg, section) []:

Common Name (eg, your name or your server's hostname) []:192.168.1.196

Email Address []:


### 生成鉴权密码文件

注意使用时admin替换为你自己的用户名，password替换为你自己的密码。

[root@docker-registry ~]# docker run --entrypoint htpasswd registry:2 -Bbn admin password  > htpasswd

没有registry这个镜像会自动下载


### 将docker-compose.yml、registry-config.yml文件放入docker-registry文件夹中

[root@docker-registry ~]# ls docker-registry/

docker-compose.yml  htpasswd  openssl.cnf  registry-config.yml  server.cert  server.key


### 配置认证

[root@docker-registry docker-registry]# cp htpasswd /srv/docker/auth/

[root@docker-registry docker-registry]# cp server.* /srv/docker/certs/

[root@docker-registry docker-registry]# cp registry-config.yml /srv/docker/registry/config.yml

注意这三个文件需要给777权限


### 配置秘钥

[root@docker-registry docker-registry]# mkdir /etc/docker/certs.d/192.168.1.204\:5000/

[root@docker-registry docker-registry]# cp server.cert /etc/docker/certs.d/192.168.1.204\:5000/ca.crt

[root@docker-registry docker-registry]# systemctl restart docker


### 启动仓库

[root@docker-registry docker-registry]# docker-compose up
Creating dockerregistry_registry_1 ... done
Attaching to dockerregistry_registry_1
registry_1  | time="2018-03-07T03:14:17Z" level=warning msg="No HTTP secret provided - generated random secret. This may cause problems with uploads if multiple registries are behind a load-balancer. To provide a shared secret, fill in http.secret in the configuration file or set the REGISTRY_HTTP_SECRET environment variable." go.version=go1.7.6 instance.id=b3b26165-a909-4c6c-b04a-9446135ceaa0 version=v2.6.2 
registry_1  | time="2018-03-07T03:14:17Z" level=info msg="redis not configured" go.version=go1.7.6 instance.id=b3b26165-a909-4c6c-b04a-9446135ceaa0 version=v2.6.2 
registry_1  | time="2018-03-07T03:14:17Z" level=info msg="Starting upload purge in 5m0s" go.version=go1.7.6 instance.id=b3b26165-a909-4c6c-b04a-9446135ceaa0 version=v2.6.2 
registry_1  | time="2018-03-07T03:14:17Z" level=info msg="using inmemory blob descriptor cache" go.version=go1.7.6 instance.id=b3b26165-a909-4c6c-b04a-9446135ceaa0 version=v2.6.2 
registry_1  | time="2018-03-07T03:14:17Z" level=info msg="listening on [::]:5000, tls" go.version=go1.7.6 instance.id=b3b26165-a909-4c6c-b04a-9446135ceaa0 version=v2.6.

### 登陆认证

[root@docker-registry docker-registry]# docker login 192.168.1.204:5000

Username (admin): admin

Password: 

Login Succeeded


### 配置客户机

将server.certs文件传到客户机的/etc/docker/certs.d/下面

[root@docker-registry docker-registry]# scp server.cert root@192.168.1.206:/etc/docker/certs.d/

客户机操作：

[root@localhost docker-registry]# cd /etc/docker/certs.d/ && mkdir 192.168.1.204\:5000/

[root@localhost docker-registry]# mv server.cert 192.168.1.204\:5000/ca.crt

[root@localhost docker-registry]# systemctl restart docker

[root@localhost docker-registry]# docker login 192.168.1.204:5000

Username (admin): admin

Password: 

Login Succeeded


### 客户机测试上传镜像

先从公有仓库下载一个nginx镜像

[root@localhost ~]# docker pull nginx

[root@localhost ~]# docker images

REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE

docker.io/nginx      latest              e548f1a579cf        2 weeks ago         108.6 MB

重新打个标签

[root@localhost ~]# docker tag e548f1a579cf 192.168.1.204:5000/nginx:latest

[root@localhost ~]# docker images

REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE

192.168.1.204:5000/nginx   latest              e548f1a579cf        2 weeks ago         108.6 MB

docker.io/nginx            latest              e548f1a579cf        2 weeks ago         108.6 MB

[root@localhost ~]# docker push 192.168.1.204:5000/nginx

The push refers to a repository [192.168.1.204:5000/nginx]

e89b70d28795: Pushed 

832a3ae4ac84: Pushed 

014cf8bfcb2d: Pushed 

latest: digest: sha256:600bff7fb36d7992512f8c07abd50aac08db8f17c94e3c83e47d53435a1a6f7c size: 948
