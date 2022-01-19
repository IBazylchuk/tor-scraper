FROM ruby:2.7.4

RUN apt-get update -qq && apt-get install -y tor

ENV FIRST_SOCKS_PORT=9101
ENV LAST_SOCKS_PORT=9199

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

RUN echo "ExitNodes {us}" >> /etc/torrc

ADD configure_socks_ports.sh /tmp/configure_socks_ports.sh
RUN chmod +x /tmp/configure_socks_ports.sh

ADD start.sh /
RUN chmod +x /start.sh

# ENTRYPOINT ["/tmp/configure_socks_ports.sh"]
# CMD ["sh", "-c", "tor -f /etc/torrc ; /usr/sbin/php5-fpm"]
# CMD ["tor -f /etc/torrc", "&&", "bundle exec puma /app -t 5:5"]
CMD ["/start.sh"]
EXPOSE 9292
