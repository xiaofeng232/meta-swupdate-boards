#!/bin/bash

# 1. delete leftover build containers
echo "deleting leftover build containers..."
docker container prune -f

# 2. delete dangling images
echo "deleting dangling images..."
docker rmi -f 19b82d56b056 2>/dev/null

# 3. delete old images
echo "deleting old images..."
docker rmi -f ubuntu:trusty alpine:3.9 hello-world 2>/dev/null

# 4. clear build cache
echo "clearing build cache..."
docker builder prune -f

echo "Docker cleanup completed."
docker images
echo "==============================="
echo "existing containers:"
docker ps -a
echo "==============================="
echo "existing volumes:"
docker volume ls
echo "==============================="
echo "existing networks:"
docker network ls
echo "==============================="
echo "existing buildx builders:"
docker buildx ls
echo "==============================="
echo "existing contexts:"
docker context ls
echo "==============================="
echo "existing system info:"
docker system info