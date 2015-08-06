FROM debian:jessie
MAINTAINER Ian Blenke <ian@blenke.com>

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y linux-igd

ADD run.sh /run.sh
RUN chmod 755 /run.sh

CMD /run.sh


