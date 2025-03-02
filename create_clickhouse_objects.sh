#!/bin/bash

# Set variables for the ClickHouse host and port
CLICKHOUSE_HOST="localhost"
CLICKHOUSE_PORT="9000"
CLICKHOUSE_USER="default"

# SQL queries
SQL_QUERIES="
-- Drop existing tables
DROP TABLE IF EXISTS customers_kafka;
DROP TABLE IF EXISTS customers_mv;
DROP TABLE IF EXISTS customers;

-- Create Kafka table
CREATE TABLE customers_kafka (
    message String
) ENGINE = Kafka
SETTINGS kafka_broker_list = 'kafka:9092',
         kafka_topic_list = 'dbserver1.public.customers',
         kafka_format = 'JSONAsString',
         kafka_group_name = 'clickhouse-consumer';

-- Create the target table
CREATE TABLE customers (
    id UInt32,
    name String,
    email String,
    created_at DateTime
) ENGINE = MergeTree()
ORDER BY id;

-- Create materialized view to parse and extract data
CREATE MATERIALIZED VIEW customers_mv TO customers AS
SELECT
    JSONExtractInt(JSONExtractRaw(JSONExtractRaw(message, 'payload'), 'after'), 'id') AS id,
    JSONExtractString(JSONExtractRaw(JSONExtractRaw(message, 'payload'), 'after'), 'name') AS name,
    JSONExtractString(JSONExtractRaw(JSONExtractRaw(message, 'payload'), 'after'), 'email') AS email,
    toDateTime(JSONExtractInt(JSONExtractRaw(JSONExtractRaw(message, 'payload'), 'after'), 'created_at') / 1000000) AS created_at
FROM customers_kafka
WHERE JSONExtractString(JSONExtractRaw(message, 'payload'), 'op') IN ('c', 'r', 'u');
"

# Execute the SQL queries in the ClickHouse container
docker exec -i clickhouse clickhouse-client --host=$CLICKHOUSE_HOST --port=$CLICKHOUSE_PORT --user=$CLICKHOUSE_USER --multiquery --query="$SQL_QUERIES"
