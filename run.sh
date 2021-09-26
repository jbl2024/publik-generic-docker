#!/bin/bash
python3 /opt/scripts/import_vars.py
ln -sf /apps/settings/recipe.json /etc/hobo/recipe.json
ln -sf /apps/settings/ldap.py /etc/authentic2-multitenant/settings.d/00ldap.py

ln -sf /apps/settings/common.py /etc/chrono/settings.d/00common.py

ln -sf /apps/settings/common.py /etc/combo/settings.d/00common.py
ln -sf /apps/settings/common.py /etc/fargo/settings.d/00common.py
ln -sf /apps/settings/common.py /etc/authentic2-multitenant/settings.d/00common.py
ln -sf /apps/settings/common.py /etc/bijoe/settings.d/00common.py
ln -sf /apps/settings/common.py /etc/hobo/settings.d/00common.py
ln -sf /apps/settings/common.py /etc/hobo-agent/settings.d/00common.py
ln -sf /apps/settings/common.py /etc/passerelle/settings.d/00common.py
ln -sf /apps/settings/common.py /etc/wcs/settings.d/00common.py

rm /var/run/{authentic2-multitenant/authentic2-multitenant,chrono/chrono,fargo/fargo,hobo/hobo,combo/combo,nginx,rsyslogd,supervisord,wcs,passerelle/passerelle,bijoe/bijoe}.{pid,sock}
mkdir -p /var/lib/authentic2-multitenant/tenants
mkdir -p /var/lib/hobo/tenants
mkdir -p /var/lib/bijoe/tenants
mkdir -p /var/lib/chrono/tenants
mkdir -p /var/lib/combo/tenants
mkdir -p /var/lib/fargo/tenants
mkdir -p /var/lib/passerelle/tenants
mkdir -p /var/lib/wcs/skeletons

chown authentic-multitenant:authentic-multitenant /var/lib/authentic2-multitenant/ -R
chown hobo:hobo /var/lib/hobo/ -R
chown bijoe:bijoe /var/lib/bijoe/ -R
chown chrono:chrono /var/lib/chrono/ -R
chown combo:combo /var/lib/combo/ -R
chown fargo:fargo /var/lib/fargo/ -R
chown passerelle:passerelle /var/lib/passerelle/ -R
chown wcs:wcs /var/lib/wcs -R

service rsyslog start
service cron start

service combo start
service authentic2-multitenant update
service authentic2-multitenant start
service wcs start
service passerelle start
service hobo start
service fargo start
service bijoe update
service bijoe start
service chrono start
service nginx start
service supervisor start

# install skeletons
cp /apps/settings/config.json /tmp/config.json
cp /apps/settings/site-options.cfg /tmp/site-options.cfg
cd /tmp && zip /tmp/publik.zip site-options.cfg config.json
cp /tmp/publik.zip /var/lib/wcs/skeletons/

sudo -u hobo hobo-manage cook /etc/hobo/recipe.json --timeout=360

tail -f /var/log/syslog
