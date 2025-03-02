#!/bin/bash

echo "🔗 Connecting to Postgres container and logging into testdb..."
docker exec -it postgres psql -U postgres -d testdb
