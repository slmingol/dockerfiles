FROM eboraas/debootstrap:minbase-sid
MAINTAINER Christian-Maxilian Steier

ADD http://http.debian.net/debian/project/trace/ftp-master.debian.org /etc/trace_ftp-master.debian.org
ADD http://security.debian.org/project/trace/security-master.debian.org /etc/trace_security-master.debian.org

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y dist-upgrade 

# Set timezone
RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Install basics
RUN apt-get install  -y vim supervisor wget libxml2 libxslt1.1 logrotate php5-fpm

#php5-fpm
RUN rm /etc/php5/fpm/pool.d/www.conf
ADD conf/www.conf /etc/php5/fpm/pool.d/www.conf
RUN /etc/init.d/php5-fpm start

# Hiawatha
RUN apt-key adv --recv-keys --keyserver keys.gnupg.net DC242980 && \
    echo 'deb http://apt.sparkz.no/debian/ squeeze main' > /etc/apt/sources.list.d/hiawatha.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install hiawatha

# Clean up APT when done.
RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD scripts/start.sh /start.sh
ADD scripts/run.sh /run.sh
RUN chmod 755 /*.sh
ADD conf/supervisord-hiawatha.conf /etc/supervisor/conf.d/supervisord-hiawatha.conf
ADD conf/supervisord-php.conf /etc/supervisor/conf.d/supervisord-php.conf

EXPOSE 80
CMD ["/run.sh"]
