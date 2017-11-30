FROM phusion/passenger-ruby23:0.9.27
ENV HOME /root
CMD ["/sbin/my_init"]
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN apt-get update
RUN apt-get install -y build-essential
RUN gem install bundler

ENV APP_HOME /home/app/webapp

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
COPY vendor $APP_HOME/vendor
RUN bundle install --deployment --without development test
RUN rm -fr vendor/cache

COPY anadict /usr/share/dict/anadict
COPY Rakefile $APP_HOME/Rakefile
COPY config.ru $APP_HOME/config.ru
COPY app.rb $APP_HOME/app.rb
COPY assets $APP_HOME/assets
COPY lib $APP_HOME/lib
COPY views $APP_HOME/views

RUN bundle exec rake assets:precompile RACK_ENV=production

RUN rm /etc/nginx/sites-enabled/default
ADD docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf

RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/service/sshd/down
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER root
