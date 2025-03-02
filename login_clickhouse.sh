#!/bin/bash

echo "🔗 Connecting to ClickHouse container and logging into default database..."
docker exec -it clickhouse clickhouse-client --host localhost
