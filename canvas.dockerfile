FROM nginx/unit:1.29.1-ruby3.1

WORKDIR /var/www/canvas

SHELL ["/bin/bash", "-c"]

RUN apt update -y
RUN git clone --branch prod --depth 1 https://github.com/instructure/canvas-lms.git .
RUN apt-get install software-properties-common -y
RUN apt-get update -y
RUN apt install -y zlib1g-dev libxml2-dev \
    libsqlite3-dev postgresql libpq-dev \
    libxmlsec1-dev libyaml-dev libidn11-dev curl make g++
    # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    # source ~/.bashrc && \
    # nvm install 18 && \
    # nvm use 18 && \
    # source ~/.bashrc && \
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&\
    apt-get install -y nodejs
RUN npm install -g yarn    
    # source ~/.bashrc && \
RUN gem install bundler --version 2.4.19
RUN bundle config set --local path vendor/bundle
RUN bundle install
RUN yarn install
RUN for config in amazon_s3 database \
    delayed_jobs domain file_store outgoing_mail security external_migration; \
    do cp config/$config.yml.example config/$config.yml; done
RUN cp config/dynamic_settings.yml.example config/dynamic_settings.yml 

COPY ./config/database.yml config/database.yml
COPY ./config/domain.yml config/domain.yml
COPY ./config/dynamic_settings.yml config/dynamic_settings.yml
COPY ./config/redis.yml config/redis.yml
COPY ./config/security.yml config/security.yml

RUN yarn gulp rev
RUN RAILS_ENV=production bundle exec rake db:initial_setup

SHELL ["/bin/sh", "-c"]
