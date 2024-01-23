FROM ubuntu

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && \
    apt install -y software-properties-common zlib1g-dev libxml2-dev libsqlite3-dev postgresql libpq-dev libxmlsec1-dev libyaml-dev libidn11-dev curl make g++ libcurl4-openssl-dev ruby-dev vim nano git rbenv && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build && \
    rbenv install 3.1.0 && \
    rbenv global 3.1.0 && \
    gem install passenger -v 6.0.20 && \
    passenger-install-nginx-module && \
    echo 'alias nginx=/opt/nginx/sbin/nginx' >> ~/.bashrc && \
    apt clean

WORKDIR /var/www/canvas

RUN git clone --branch prod --depth 1 https://github.com/instructure/canvas-lms.git . && \
    for config in amazon_s3 database delayed_jobs domain file_store outgoing_mail security external_migration; \
    do cp config/$config.yml.example config/$config.yml; done && \
    cp config/dynamic_settings.yml.example config/dynamic_settings.yml && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&\
    apt-get install -y nodejs && \
    npm install -g yarn && \
    yarn install && \
    apt clean

COPY ./config/database.yml config/database.yml
COPY ./config/domain.yml config/domain.yml
COPY ./config/dynamic_settings.yml config/dynamic_settings.yml
COPY ./config/redis.yml config/redis.yml
COPY ./config/security.yml config/security.yml
COPY ./canvas.conf /opt/nginx/conf/nginx.conf
COPY ./script.sh /root/script.sh

RUN chmod +x /root/script.sh

ENV RAILS_ENV=production
ENV CANVAS_LMS_ADMIN_EMAIL=example@example.com
ENV CANVAS_LMS_ADMIN_PASSWORD=adminadmin
ENV CANVAS_LMS_ACCOUNT_NAME=example
ENV CANVAS_LMS_STATS_COLLECTION=3

CMD [ "/root/script.sh" ]
