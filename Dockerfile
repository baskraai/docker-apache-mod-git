FROM ubuntu:bionic
LABEL Maintainer Bas Kraai <bas@kraai.email>

ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN apt-get update \
    && apt-get install --no-install-recommends -y apache2 git rsync \
    openssh-client apache2 libapache2-mod-auth-openidc nginx php libapache2-mod-php php-mysql \
    && rm -rf /var/lib/apt/lists/*

run a2enmod ssl rewrite headers proxy proxy_http proxy_balancer lbmethod_byrequests \
    auth_openidc proxy_wstunnel

EXPOSE 80 443

COPY ./.scripts/helpfunctions.sh /
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
