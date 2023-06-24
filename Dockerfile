FROM debian:buster
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
# Update Packages List
RUN echo "APT::Install-Suggests \"false\";\nAPT::Install-Recommends \"false\";" >> /etc/apt/apt.conf
# Don't allow services to start when building the image
RUN echo "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

# Install base packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nginx \
    sudo \
    wget \
    gnupg \
    debian-archive-keyring \
    rsyslog \
    gettext \
    vim.nox \
    bash-completion \
    libjs-jquery \
    libreoffice \
    cron \
    lftp \
    procps \
    apt-transport-https \
    ca-certificates \
    rsync \
    ssl-cert \
    curl \
    zip \
    unzip

# Install EO packages
RUN echo 'deb http://deb.debian.org/debian/ buster-backports main' > /etc/apt/sources.list.d/backports.list && \
    echo 'deb http://deb.entrouvert.org/ buster main' > /etc/apt/sources.list.d/entrouvert.list && \
    curl https://deb.entrouvert.org/entrouvert.gpg | sudo tee -a /etc/apt/trusted.gpg.d/entrouvert.gpg && \
    apt update && \
    yes | apt install -o Dpkg::Options::="--force-confnew" entrouvert-repository && \
    yes | apt install entrouvert-repository-hotfix && \
    apt update && \
    apt install -y \  
    python3-sentry-sdk \
    python-configparser \
    poppler-utils \
    python3-dns \
    python3-docutils \
    python3-langdetect \
    python3-magic \
    python3-qrcode \
    python3-workalendar

RUN apt install -y publik-base-theme \
    publik-common \
    combo \
    wcs wcs-au-quotidien \
    fargo \
    hobo \
    bijoe \
    chrono \
    passerelle \
    hobo \
    hobo-agent \
    authentic2-multitenant

# Allow services to start, this is necessary as hobo-agent postinst will fail
# if supervisord is not running
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d && \
    echo "server_names_hash_bucket_size 128;" > /etc/nginx/conf.d/server_names.conf

# Cleanup
RUN apt-get -y remove python-dev && apt-get -y autoremove && apt-get clean
COPY run.sh /
RUN chmod +x /run.sh
RUN echo "Europe/Paris" > /etc/timezone && \
    dpkg-reconfigure tzdata

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

RUN cp /usr/share/doc/publik-common/nginx/conf.d/* /etc/nginx/conf.d/ && \
    cp -r /usr/share/doc/publik-common/nginx/sites-available/* /etc/nginx/sites-enabled/ && \ 
    rm /etc/nginx/sites-enabled/default

RUN curl https://doc-publik.entrouvert.com/media/certificates/dev.publik.love/fullchain.pem > /etc/ssl/certs/publik-fullchain.pem
RUN curl https://doc-publik.entrouvert.com/media/certificates/dev.publik.love/privkey.pem > /etc/ssl/private/publik-privkey.pem
WORKDIR /etc/nginx/sites-enabled/
RUN find . -exec sed -i 's/ssl-cert-snakeoil.pem/publik-fullchain.pem/g' {} \;
RUN find . -exec sed -i 's/ssl-cert-snakeoil.key/publik-privkey.pem/g' {} \;
RUN openssl dhparam -out /etc/ssl/dhparam2048.pem 2048

EXPOSE 80
# Run
CMD ["/run.sh"]
