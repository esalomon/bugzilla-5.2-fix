FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install \
apache2 \
build-essential \
dos2unix \
graphviz \
libapache2-mod-perl2 \
libapache2-mod-perl2-dev \
libappconfig-perl \
libauthen-radius-perl \
libauthen-sasl-perl \
libchart-perl \
libcgi-pm-perl \
libdaemon-generic-perl \
libdate-calc-perl \
libdatetime-perl \
libdatetime-timezone-perl \
libdbi-perl \
libdbix-connector-perl \
libencode-detect-perl \
libemail-address-perl \
libemail-mime-modifier-perl \
libemail-mime-perl \
libemail-sender-perl \
libfile-mimeinfo-perl \
libfile-slurp-perl \
libgd-dev \
libgd-graph-perl \
libhtml-formattext-withlinks-perl \
libhtml-scrubber-perl \
libjson-rpc-perl \
liblocale-codes-perl \
libmath-random-isaac-perl \
libmath-random-isaac-xs-perl \
libmodule-build-perl \
libmysqlclient-dev \
libnet-ldap-perl \
libsoap-lite-perl \
libtemplate-perl \
libtemplate-plugin-gd-perl \
libtest-taint-perl \
libtheschwartz-perl \
libxml-perl \
libxml-twig-perl \
mariadb-client \
netcat-traditional \
perlmagick \
tzdata \
vim-common && \
  ln -sf /usr/share/zoneinfo/"$TZ" /etc/localtime && echo "$TZ" > /etc/timezone && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Ubuntu22 doesn't ship new enough versions of a few modules, so get them from CPAN
RUN cpan install Template::Toolkit Email::Address::XS Email::Sender DBD::MariaDB

# Distribution package installation
COPY docker /root/docker

# Convert all text files to Unix line endings
RUN dos2unix /root/docker/mysql/bugzilla.cnf \
    && find /root/docker -type f -exec dos2unix {} \; && \
    cp /root/docker/000-default.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html
COPY --chown=root:www-data . /var/www/html

# we don't want Docker droppings accessible by the web browser since they
# might contain setup info you don't want public
RUN rm -rf /var/www/html/docker* /var/www/html/Dockerfile* && \
    rm -rf /var/www/html/data /var/www/html/localconfig /var/www/html/index.html && \
    mkdir /var/www/html/data && \
    a2enmod expires && a2enmod headers && a2enmod rewrite && a2dismod mpm_event && a2enmod mpm_prefork
EXPOSE 80/tcp
CMD ["/root/docker/startup.sh"]
