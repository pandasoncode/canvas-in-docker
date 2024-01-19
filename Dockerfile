FROM ubuntu

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y

RUN apt install -y software-properties-common

RUN apt install -y zlib1g-dev libxml2-dev \
    libsqlite3-dev postgresql libpq-dev \
    libxmlsec1-dev libyaml-dev libidn11-dev curl make g++ libcurl4-openssl-dev ruby-dev

RUN apt install -y vim nano git

RUN apt install -y rbenv

RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc

RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

RUN rbenv install 3.1.0
RUN rbenv global 3.1.0

RUN gem install passenger
RUN passenger-install-nginx-module

RUN echo 'alias nginx=/opt/nginx/sbin/nginx' >> ~/.bashrc

WORKDIR /var/www/canvas

RUN git clone --branch prod --depth 1 https://github.com/instructure/canvas-lms.git .
RUN for config in amazon_s3 database \
    delayed_jobs domain file_store outgoing_mail security external_migration; \
    do cp config/$config.yml.example config/$config.yml; done

RUN cp config/dynamic_settings.yml.example config/dynamic_settings.yml

COPY ./config/database.yml config/database.yml
COPY ./config/domain.yml config/domain.yml
COPY ./config/dynamic_settings.yml config/dynamic_settings.yml
COPY ./config/redis.yml config/redis.yml
COPY ./config/security.yml config/security.yml

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&\
    apt-get install -y nodejs
RUN npm install -g yarn    
    # source ~/.bashrc && \
# RUN gem install bundler --version 2.4.19
# RUN bundle config set --local path vendor/bundle
# RUN bundle install
RUN yarn install

COPY ./script.sh /root/script.sh
RUN chmod +x /root/script.sh
