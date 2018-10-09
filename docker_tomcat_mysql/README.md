# 利用tomcat容器部署多个java环境及mysql数据库


## 首先需要下载一个tomcat容器及一个mysql容器，此例用到的是tomcat:8.0-jre8和mysql:5.6

docker pull tomcat:8.0-jre8

docker pull mysql:5.6

## 并自作一个api容器

cd api_build

docker build -t tomcat-api:0.1 .


## 修改tomcat项目配置

1、此例中使用有个tomcat容器，避免端口冲突，注意将web02项目的端口号修改为8081

2、注意修改连接mysql数据库配置文件，将地址都改为mysql；数据库密码为root，可自行修改，但注意修改docker-compose.yml文件中的MYSQL_ROOT_PASSWORD参数

application.properties

spring.datasource.url = jdbc:mysql://mysql/web01？

3、注意修改连接api地址配置参数，将地址改为api

apiserver.address: http://api

4、修改完成后生成war包，将两个war包名称都改为ROOT.war，分别放入web01和web02目录中


## 启动容器

docker-compose up

