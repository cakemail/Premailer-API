# vim: set expantab ts=2
FROM debian:wheezy

MAINTAINER sebastien@cakemail.com

ENV PROJECT_PATH /opt/cakemail/sinatra-apps/premailer

RUN apt-get update && \
    apt-get install -y \
      apache2 \
      libapache2-mod-passenger \
      ruby1.8 \
      ruby1.8-dev \
      sudo \
      git \
      rsyslog \
      supervisor \
      python-requests \
      python-boto && \
    apt-get clean

RUN gem install bundler --no-ri --no-rdoc

# configure apache
RUN a2dissite 000-default
RUN a2enmod rewrite
ADD docker/apache2/premailer.conf /etc/apache2/sites-available/premailer
RUN a2ensite premailer
RUN a2enmod headers

# deploy user
RUN useradd -u 1050 -G www-data -m -d /home/cake cake

# remote logging
ADD docker/rsyslog/remote.conf /etc/rsyslog.d/remote.conf
ADD docker/supervisor/supervisord.conf /etc/supervisord.conf

# prepare directories
RUN mkdir -p ${PROJECT_PATH}
RUN chown -R cake:cake ${PROJECT_PATH}

# passenger logging
RUN mkdir -p /var/log/passenger
RUN chown cake:cake /var/log/passenger

# deploy the project
ADD . ${PROJECT_PATH}
RUN chown -R cake:cake ${PROJECT_PATH}
RUN sudo su cake -c "cd /opt/cakemail/sinatra-apps/premailer && bundle install --quiet --deployment --path=${PROJECT_PATH}/bundle"

EXPOSE 80

CMD /usr/bin/supervisord 
