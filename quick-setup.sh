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
