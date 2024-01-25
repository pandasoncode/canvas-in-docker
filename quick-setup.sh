#!/bin/bash

# Check if network exists
docker network inspect canvas

# If network does not exist, create it
if [ $? -eq 1 ]; then
    docker network create canvas
fi

# Create postgres container
docker run -d \
    --name postgres \
    -e POSTGRES_PASSWORD=admin \
    -e POSTGRES_USER=canvas \
    -e POSTGRES_DB=canvas_production \
    --network canvas \
    postgres

# Create redis container
docker run -d \
    --name redis \
    --network canvas \
    redis

# Create kinesis container
docker run -d \
    --name kinesis.canvaslms.docker \
    -p 4567:4567 \
    --network canvas \
    instructure/kinesalite

# Create stream
AWS_ACCESS_KEY_ID=x AWS_SECRET_ACCESS_KEY=x \
    aws --endpoint-url http://localhost:4567/ \
    kinesis create-stream \
    --stream-name=live-events \
    --shard-count=1

# Build canvas image
docker image build -t canvas -f canvas.dockerfile .

# Create canvas container
docker run -it \
    --name canvas \
    --network canvas \
    -p443:443 \
    -p8080:80 \
    -e DATABASE_POPULATION=1 \
    canvas
