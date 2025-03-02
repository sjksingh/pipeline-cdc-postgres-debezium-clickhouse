# Postgres-Clickhouse-Kafka CDC Pipeline

A complete Change Data Capture (CDC) pipeline using Debezium, Kafka, PostgreSQL, and ClickHouse. This project demonstrates how to capture data changes from PostgreSQL in real-time and stream them to ClickHouse for analytics.

## Architecture

The architecture follows this data flow:

```
PostgreSQL → Debezium Connect → Kafka → ClickHouse
```

### Components and Ports:
- **PostgreSQL (5432)**: Source database where changes are captured
- **Debezium Connect (8083)**: Captures changes from PostgreSQL using CDC
- **Zookeeper (2181)**: Manages Kafka broker
- **Apache Kafka (9092)**: Message broker for streaming CDC events
- **Kafdrop (9000)**: Web UI for monitoring Kafka topics
- **ClickHouse (8123/9001)**: Analytics database for storing processed events

### Data Flow:
1. PostgreSQL changes are captured by Debezium Connect
2. Change events flow through Kafka to monitoring and analytics systems
3. Kafdrop provides web UI for monitoring Kafka topics
4. ClickHouse stores data for analytics queries

## Prerequisites

- Docker and Docker Compose
- Git
- bash (for running the setup script)

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/sjksingh/pipeline-cdc-postgres-debezium-clickhouse
cd kafka-cdc-pipeline
```

### 2. Start the containers

```bash
docker-compose up -d
```

This will start all services defined in the docker-compose.yml file.

### 3. Run the setup script

```bash
chmod +x setup.sh
./setup.sh
```

The setup script will:
- Create a test database and table in PostgreSQL
- Insert sample data
- Configure the Debezium connector to capture changes

### 4. Access the services

| Service | URL | Description |
|---------|-----|-------------|
| Kafdrop | http://localhost:9000 | Kafka UI - view topics and messages |
| Debezium Connect | http://localhost:8083 | Connect REST API |
| ClickHouse HTTP | http://localhost:8123 | ClickHouse HTTP interface |
| PostgreSQL | localhost:5432 | PostgreSQL database |

## Testing the Pipeline

### 1. View CDC events in Kafdrop

Open http://localhost:9000 in your browser and navigate to the topic `dbserver1.public.customers`. You should see the initial data load messages.

### 2. Make changes to the PostgreSQL database

```bash
PGPASSWORD=postgres psql -h localhost -U postgres -d testdb -c "INSERT INTO customers (name, email) VALUES ('New User', 'new@example.com');"
```

### 3. Verify the changes were captured

Check Kafdrop again to see the new message in the topic.

## Container Access Commands

### PostgreSQL

```bash
# Access PostgreSQL CLI
docker exec -it postgres psql -U postgres -d testdb

# Execute a query directly
docker exec -it postgres psql -U postgres -d testdb -c "SELECT * FROM customers;"
```

### Kafka

```bash
# List topics
docker exec -it kafka /kafka/bin/kafka-topics.sh --list --bootstrap-server kafka:9092

# Consume messages from a topic
docker exec -it kafka /kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic dbserver1.public.customers --from-beginning
```

### Debezium Connect

```bash
# View connector status
curl -s http://localhost:8083/connectors/postgres-connector/status

# Delete connector
curl -X DELETE http://localhost:8083/connectors/postgres-connector
```

### ClickHouse

```bash
# Access ClickHouse CLI
docker exec -it clickhouse clickhouse-client

# Execute a query
docker exec -it clickhouse clickhouse-client --query "SHOW DATABASES"
```

### View logs for any container

```bash
docker-compose logs kafka
docker-compose logs connect
docker-compose logs postgres
```

## Customization

You can modify the PostgreSQL schema and Debezium connector configuration in the `setup.sh` script to capture changes from your own tables.

## Troubleshooting

If you encounter issues with the connector, check the logs:

```bash
docker logs connect
```

## License

MIT
