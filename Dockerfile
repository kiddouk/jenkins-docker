FROM jenkins

MAINTAINER Sebastien Requiem<sebastien.requiem@gmail.com>
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
