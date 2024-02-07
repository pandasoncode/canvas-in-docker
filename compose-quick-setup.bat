@echo off
docker image build -t canvas -f Dockerfile .

set DATABASE_POPULATION=true
docker stack deploy -c docker-compose.yml canvas
