#!/bin/bash

# Wait for services to be up
echo "Waiting for services to be up..."
sleep 5

# Create test database and table in Postgres
echo "Creating test database and table in Postgres..."
PGPASSWORD=postgres psql -h localhost -U postgres -c "DROP DATABASE IF EXISTS testdb;"
PGPASSWORD=postgres psql -h localhost -U postgres -c "CREATE DATABASE testdb;"
PGPASSWORD=postgres psql -h localhost -U postgres -d testdb -c "
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(200),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE customers REPLICA IDENTITY FULL;
"


# Insert some test data
echo "Inserting test data..."
PGPASSWORD=postgres psql -h localhost -U postgres -d testdb -c "
INSERT INTO customers (name, email) VALUES
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com'),
('Sanjeev Singh', 'Sanjeev@Singh.com')
;"

# Configure Debezium connector
echo "Configuring Debezium connector for Postgres CDC..."
curl -X POST -H "Accept:application/json" -H "Content-Type:application/json" http://localhost:8083/connectors -d '{
  "name": "postgres-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "tasks.max": "1",
    "database.hostname": "postgres",
    "database.port": "5432",
    "database.user": "postgres",
    "database.password": "postgres",
    "database.dbname": "testdb",
    "topic.prefix": "dbserver1",
    "schema.include.list": "public",
    "table.include.list": "public.customers",
    "plugin.name": "pgoutput"
  }
}'

# Check if connector was created successfully
echo "Checking connector status..."
sleep 2
CONNECTORS=$(curl -s http://localhost:8083/connectors)
if [[ $CONNECTORS == *"postgres-connector"* ]]; then
    echo "Connector created successfully!"
    echo "Connector status:"
    curl -s http://localhost:8083/connectors/postgres-connector/status
else
    echo "Connector not created. Available connectors: $CONNECTORS"
    echo "Check for error messages above."
fi

echo "Setup completed!"
