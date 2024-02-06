#!/bin/bash
docker image build -t canvas -f Dockerfile .

DATABASE_POPULATION=true docker stack deploy -c docker-compose.yml canvas

AWS_ACCESS_KEY_ID=x AWS_SECRET_ACCESS_KEY=x \
    aws --endpoint-url http://localhost:4567/ \
    kinesis create-stream \
    --stream-name=live-events \
    --shard-count=1
