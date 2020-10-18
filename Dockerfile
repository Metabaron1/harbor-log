FROM photon:3.0

RUN tdnf install -y cronie rsyslog logrotate shadow tar gzip sudo >> /dev/null\
    && mkdir /var/spool/rsyslog \
    && groupadd -r -g 10000 syslog && useradd --no-log-init -r -g 10000 -u 10000 syslog \
    && tdnf clean all

COPY rsyslog.conf /etc/rsyslog.conf

# rsyslog configuration file for docker
COPY rsyslog_docker.conf /etc/rsyslog.d/

# remove the original "logrotate" in directory "/etc/cron.daily/"
# and copy the customized one to directory "/etc/cron.hourly/" 
# to run logrotate hourly
RUN rm /etc/cron.daily/logrotate
COPY logrotate /etc/cron.hourly/

COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh /etc/rsyslog.d/ && \
    chown -R 10000:10000 /etc/rsyslog.conf /etc/rsyslog.d/ /run /var/lib/logrotate/

RUN chage -M 99999 root

HEALTHCHECK CMD netstat -ltun|grep 10514

VOLUME /var/log/docker/ /run/ /etc/logrotate.d/

EXPOSE 10514

CMD /usr/local/bin/start.sh
