FROM centos:7

MAINTAINER zhangxin <zhangxin@powerun.org.cn>

RUN set -x \
    && install_Pkgs=" \
        tar \
        unzip \
        bc \
        which \
        lsof \
        java-1.8.0-openjdk-headless \
    " \
    && yum install -y $install_Pkgs \
    && yum clean all -y \
    && echo

ARG jarTgt
ARG javaOpt

ENV JAVA_OPTIONS="${javaOpt:-'-Xms128m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=256m'}"

COPY api-0.1.1-SNAPSHOT.jar /api-0.1.1-SNAPSHOT.jar

EXPOSE 8090

CMD java -Djava.security.egd=file:/dev/./urandom $JAVA_OPTIONS -jar /api-0.1.1-SNAPSHOT.jar

