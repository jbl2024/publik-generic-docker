FROM debian:stretch
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
# Update Packages List
RUN echo "APT::Install-Suggests \"false\";\nAPT::Install-Recommends \"false\";" >> /etc/apt/apt.conf
# Don't allow services to start when building the image
RUN echo "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

# Install packages
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y nginx wget gnupg debian-archive-keyring rsyslog python-dns gettext vim.nox bash-completion libjs-jquery libreoffice cron lftp procps apt-transport-https ca-certificates rsync

RUN echo 'deb http://deb.debian.org/debian/ stretch-backports main' > /etc/apt/sources.list.d/backports.list
RUN echo 'deb http://deb.entrouvert.org/ stretch main' > /etc/apt/sources.list.d/entrouvert.list
RUN wget -O- https://deb.entrouvert.org/entrouvert.gpg | apt-key add -
RUN apt update
RUN yes | apt install -y entrouvert-repository
RUN apt update
RUN apt install -y publik-base-theme
RUN apt install -y publik-common
RUN apt install -y combo 
RUN apt install -y wcs wcs-au-quotidien 
RUN apt install -y fargo 
RUN apt install -y hobo 
RUN apt install -y bijoe 
RUN apt install -y chrono 
RUN apt install -y passerelle 
RUN apt install -y hobo hobo-agent 
RUN apt install -y authentic2-multitenant
RUN apt install -y zip unzip
RUN apt install -y python-raven
RUN apt install -y python3-sentry-sdk
RUN apt install -y python-configparser

# Allow services to start, this is necessary as hobo-agent postinst will fail
# if supervisord is not running
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
RUN echo "server_names_hash_bucket_size 128;" > /etc/nginx/conf.d/server_names.conf
RUN apt-get install -y -t stretch hobo-agent

# Cleanup
RUN apt-get -y remove python-dev && apt-get -y autoremove
RUN apt-get clean
COPY run.sh /
RUN chmod +x /run.sh
RUN echo "Europe/Paris" > /etc/timezone
RUN dpkg-reconfigure tzdata

ADD ./config/chrono/secret /etc/chrono/secret
ADD ./config/chrono/settings.d /etc/chrono/settings.d
ADD ./config/combo/secret /etc/combo/secret
ADD ./config/combo/settings.d /etc/combo/settings.d
ADD ./config/fargo/secret /etc/fargo/secret
ADD ./config/fargo/settings.d /etc/fargo/settings.d
ADD ./config/authentic2/secret /etc/authentic2-multitenant/secret
ADD ./config/authentic2/settings.d /etc/authentic2-multitenant/settings.d
ADD ./config/authentic2/settings.json /etc/authentic2-multitenant/settings.json
ADD ./config/bijoe/secret /etc/bijoe/secret
ADD ./config/bijoe/settings.d /etc/bijoe/settings.d
ADD ./config/hobo/secret /etc/hobo/secret
ADD ./config/hobo/extra /etc/hobo/extra
ADD ./config/hobo/settings.d /etc/hobo/settings.d
ADD ./config/hobo-agent/settings.d /etc/hobo-agent/settings.d
ADD ./config/passerelle/secret /etc/passerelle/secret
ADD ./config/passerelle/settings.d /etc/passerelle/settings.d
ADD ./config/wcs/settings.d /etc/wcs/settings.d

ADD ./scripts /opt/scripts

ADD ./connectors /opt/connectors

EXPOSE 80
# Run
CMD ["/run.sh"]
